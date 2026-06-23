// FILE: supabase/functions/presence/index.ts

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
    const adminClient = createAdminClient();

    // Handle GET presence query
    if (req.method === "GET") {
      const url = new URL(req.url);
      const targetUserId = url.searchParams.get("userId");
      
      if (!targetUserId) {
        return new Response(JSON.stringify({ error: "Missing userId parameter" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const { data: profile, error } = await adminClient
        .from("profiles")
        .select("is_online, last_seen")
        .eq("id", targetUserId)
        .maybeSingle();

      if (error) throw error;
      if (!profile) {
        return new Response(JSON.stringify({ error: "Profile not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      return new Response(JSON.stringify({
        isOnline: profile.is_online,
        lastSeen: profile.last_seen,
      }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Handle POST presence update
    if (req.method === "POST") {
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
      const { status } = await req.json();

      if (status !== "online" && status !== "offline") {
        return new Response(JSON.stringify({ error: "Invalid status value" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const isOnline = status === "online";
      const lastSeen = new Date().toISOString();

      // Update Database profiles
      const { error: dbErr } = await adminClient
        .from("profiles")
        .update({
          is_online: isOnline,
          last_seen: lastSeen,
        })
        .eq("id", userId);

      if (dbErr) throw dbErr;

      // Broadcast presence change
      await broadcastRealtime(adminClient, `presence:${userId}`, "presence_update", {
        isOnline,
        lastSeen,
      });

      return new Response(JSON.stringify({ success: true, isOnline, lastSeen }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
