// FILE: supabase/functions/update-read-status/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createAdminClient, createUserClient } from "../_shared/supabase_admin.ts";

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
    const { conversationId, lastReadMessageId } = await req.json();

    if (!conversationId || !lastReadMessageId) {
      return new Response(JSON.stringify({ error: "Missing required arguments" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const adminClient = createAdminClient();

    // 1. Validate membership
    const { data: member, error: memberErr } = await adminClient
      .from("conversation_members")
      .select("id")
      .eq("conversation_id", conversationId)
      .eq("user_id", userId)
      .maybeSingle();

    if (memberErr || !member) {
      return new Response(JSON.stringify({ error: "Unauthorized access to this conversation" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Fetch the created_at timestamp of lastReadMessageId
    const { data: message, error: msgErr } = await adminClient
      .from("messages")
      .select("created_at")
      .eq("id", lastReadMessageId)
      .single();

    if (msgErr || !message) {
      return new Response(JSON.stringify({ error: "Reference message not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const lastReadCreatedAt = message.created_at;
    const readAt = new Date().toISOString();

    // 3. Update conversation_members last_read_at and reset unread_count
    await adminClient
      .from("conversation_members")
      .update({
        last_read_at: readAt,
        unread_count: 0,
      })
      .eq("conversation_id", conversationId)
      .eq("user_id", userId);

    // 4. Update message statuses to 'read' for messages before or equal to this message
    await adminClient
      .from("messages")
      .update({ status: "read" })
      .eq("conversation_id", conversationId)
      .lte("created_at", lastReadCreatedAt)
      .neq("status", "read")
      .neq("sender_id", userId);

    // 5. Broadcast Realtime receipt event
    await broadcastRealtime(adminClient, `read:${conversationId}`, "read_receipt", {
      userId,
      lastReadMessageId,
      readAt,
    });

    return new Response(JSON.stringify({ success: true, readAt }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
