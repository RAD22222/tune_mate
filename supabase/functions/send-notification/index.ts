// FILE: supabase/functions/send-notification/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createAdminClient } from "../_shared/supabase_admin.ts";
import { sendFcmNotification } from "../_shared/fcm.ts";

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const payload = await req.json();
    
    // Only proceed for message inserts
    if (payload.type !== "INSERT" || payload.table !== "messages") {
      return new Response(JSON.stringify({ message: "Ignored webhook event" }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const record = payload.record;
    const { conversation_id, sender_id, type: msgType, content, id: messageId } = record;

    const supabase = createAdminClient();

    // 1. Get sender display_name
    const { data: senderProfile } = await supabase
      .from("profiles")
      .select("display_name")
      .eq("id", sender_id)
      .single();

    const senderName = senderProfile?.display_name || "New Message";

    // 2. Query conversation members who are not the sender
    const { data: members, error: membersError } = await supabase
      .from("conversation_members")
      .select("user_id, profiles(fcm_token)")
      .eq("conversation_id", conversation_id)
      .neq("user_id", sender_id);

    if (membersError) throw membersError;

    // 3. Build text snippet body
    let bodyText = "";
    if (msgType === "text") {
      bodyText = content ? (content.length > 100 ? `${content.substring(0, 100)}...` : content) : "";
    } else if (msgType === "image") {
      bodyText = "[Photo]";
    } else if (msgType === "video") {
      bodyText = "[Video]";
    } else if (msgType === "audio") {
      bodyText = "[Voice note]";
    } else if (msgType === "file") {
      bodyText = "[File]";
    } else if (msgType === "gif") {
      bodyText = "[GIF]";
    } else {
      bodyText = "[Attachment]";
    }

    // 4. Send notification to each active token
    const notifications = [];
    if (members) {
      for (const m of members) {
        // cast profiles as any to access nested fcm_token safely
        const profile = m.profiles as any;
        const token = profile?.fcm_token;
        if (token) {
          notifications.push(
            sendFcmNotification({
              token,
              title: senderName,
              body: bodyText,
              data: {
                conversationId: conversation_id,
                messageId: messageId,
                type: "message",
              },
            })
          );
        }
      }
    }

    const results = await Promise.allSettled(notifications);
    const sentCount = results.filter((r) => r.status === "fulfilled" && r.value).length;

    return new Response(JSON.stringify({ success: true, sentCount }), {
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
