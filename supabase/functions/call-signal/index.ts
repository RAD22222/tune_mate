// FILE: supabase/functions/call-signal/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createAdminClient, createUserClient } from "../_shared/supabase_admin.ts";
import { sendFcmNotification } from "../_shared/fcm.ts";

async function broadcastRealtime(adminClient: any, channelName: string, event: string, payload: any) {
  const channel = adminClient.channel(channelName);
  await new Promise<void>((resolve) => {
    const timeout = setTimeout(() => {
      console.warn(`Realtime broadcast to ${channelName} timed out.`);
      resolve();
    }, 3000);
    channel.subscribe(async (status: string) => {
      if (status === "SUBSCRIBED") {
        await channel.send({
          type: "broadcast",
          event,
          payload,
        });
        clearTimeout(timeout);
        resolve();
      } else if (status === "CLOSED" || status === "CHANNEL_ERROR") {
        clearTimeout(timeout);
        resolve();
      }
    });
  });
  await adminClient.removeChannel(channel);
}

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const jwt = authHeader.replace("Bearer ", "");
    const userClient = createUserClient(jwt);
    const { data: { user }, error: authErr } = await userClient.auth.getUser();
    if (authErr || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const userId = user.id;
    const body = await req.json();
    const { action } = body;

    const adminClient = createAdminClient();

    if (action === "initiate") {
      const { conversationId, calleeId, type, sdpOffer } = body;
      
      // Get caller name
      const { data: callerProfile } = await adminClient
        .from("profiles")
        .select("display_name")
        .eq("id", userId)
        .single();
      const callerName = callerProfile?.display_name || "Someone";

      // Insert Call record
      const { data: callData, error: callErr } = await adminClient
        .from("calls")
        .insert({
          conversation_id: conversationId,
          caller_id: userId,
          callee_id: calleeId,
          type,
          sdp_offer: sdpOffer,
          status: "ringing",
        })
        .select()
        .single();

      if (callErr) throw callErr;
      const callId = callData.id;

      // Broadcast Realtime Signaling
      await broadcastRealtime(adminClient, `call:${calleeId}`, "incoming_call", {
        callId,
        callerId: userId,
        callerName,
        type,
        sdpOffer,
      });

      // FCM push notification to callee
      const { data: calleeProfile } = await adminClient
        .from("profiles")
        .select("fcm_token")
        .eq("id", calleeId)
        .single();

      if (calleeProfile?.fcm_token) {
        await sendFcmNotification({
          token: calleeProfile.fcm_token,
          title: "Incoming Call",
          body: `${callerName} is calling you...`,
          data: {
            callId,
            callerId: userId,
            callerName,
            type,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            notification_type: "call",
          },
        });
      }

      return new Response(JSON.stringify({ callId }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (action === "answer") {
      const { callId, sdpAnswer } = body;

      // Update call table
      const { data: callData, error: callErr } = await adminClient
        .from("calls")
        .update({
          sdp_answer: sdpAnswer,
          status: "active",
          started_at: new Date().toISOString(),
        })
        .eq("id", callId)
        .select()
        .single();

      if (callErr) throw callErr;

      // Broadcast to caller
      await broadcastRealtime(adminClient, `call:${callData.caller_id}`, "call_answered", {
        callId,
        sdpAnswer,
      });

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (action === "ice_candidate") {
      const { callId, iceCandidate, targetUserId } = body;

      // Fetch call details to append candidate
      const { data: callData } = await adminClient
        .from("calls")
        .select("ice_candidates")
        .eq("id", callId)
        .single();

      const existingCandidates = callData?.ice_candidates || [];
      const updatedCandidates = [...existingCandidates, iceCandidate];

      await adminClient
        .from("calls")
        .update({ ice_candidates: updatedCandidates })
        .eq("id", callId);

      // Broadcast to target
      await broadcastRealtime(adminClient, `call:${targetUserId}`, "ice_candidate", {
        callId,
        candidate: iceCandidate,
      });

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (action === "end") {
      const { callId } = body;

      const { data: callData } = await adminClient
        .from("calls")
        .select("caller_id, callee_id, started_at")
        .eq("id", callId)
        .single();

      if (!callData) throw new Error("Call not found");

      const endedAt = new Date();
      let durationSeconds = 0;
      if (callData.started_at) {
        const start = new Date(callData.started_at);
        durationSeconds = Math.floor((endedAt.getTime() - start.getTime()) / 1000);
      }

      await adminClient
        .from("calls")
        .update({
          status: "ended",
          ended_at: endedAt.toISOString(),
          duration_seconds: durationSeconds,
        })
        .eq("id", callId);

      const otherUserId = callData.caller_id === userId ? callData.callee_id : callData.caller_id;

      // Broadcast to other member
      await broadcastRealtime(adminClient, `call:${otherUserId}`, "call_ended", { callId });

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (action === "decline") {
      const { callId } = body;

      const { data: callData } = await adminClient
        .from("calls")
        .update({
          status: "declined",
          ended_at: new Date().toISOString(),
        })
        .eq("id", callId)
        .select()
        .single();

      if (!callData) throw new Error("Call not found");

      // Broadcast back to caller
      await broadcastRealtime(adminClient, `call:${callData.caller_id}`, "call_declined", { callId });

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (action === "miss") {
      const { callId } = body;

      const { data: callData } = await adminClient
        .from("calls")
        .update({ status: "missed" })
        .eq("id", callId)
        .select()
        .single();

      if (!callData) throw new Error("Call not found");

      // Send FCM missed call notification to caller
      const { data: callerProfile } = await adminClient
        .from("profiles")
        .select("fcm_token")
        .eq("id", callData.caller_id)
        .single();

      if (callerProfile?.fcm_token) {
        await sendFcmNotification({
          token: callerProfile.fcm_token,
          title: "Missed Call",
          body: "The call went unanswered.",
          data: {
            callId,
            type: "missed_call",
          },
        });
      }

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ error: "Invalid action" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
