// FILE: supabase/functions/search-messages/index.ts

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createAdminClient, createUserClient } from "../_shared/supabase_admin.ts";

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

    // Parse GET query parameters
    const url = new URL(req.url);
    const q = url.searchParams.get("q") || "";
    const conversationId = url.searchParams.get("conversationId");
    const limit = parseInt(url.searchParams.get("limit") || "20", 10);
    const offset = parseInt(url.searchParams.get("offset") || "0", 10);

    if (q.trim().length === 0) {
      return new Response(JSON.stringify([]), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const adminClient = createAdminClient();

    // 1. Fetch user's member conversations
    const { data: myConversations, error: myConvErr } = await adminClient
      .from("conversation_members")
      .select("conversation_id")
      .eq("user_id", userId);

    if (myConvErr) throw myConvErr;
    const convIds = myConversations ? myConversations.map((c) => c.conversation_id) : [];

    if (convIds.length === 0) {
      return new Response(JSON.stringify([]), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Filter target conversations
    if (conversationId) {
      if (!convIds.includes(conversationId)) {
        return new Response(JSON.stringify({ error: "Access denied to this conversation" }), {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }
    const targetConvIds = conversationId ? [conversationId] : convIds;

    // 3. Query messages using FTS search
    const { data: messages, error: searchErr } = await adminClient
      .from("messages")
      .select(`
        id,
        conversation_id,
        sender_id,
        content,
        created_at,
        profiles(display_name)
      `)
      .in("conversation_id", targetConvIds)
      .textSearch("content", q, { config: "english" })
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (searchErr) throw searchErr;

    // 4. Map results to array contract
    const results = (messages || []).map((m: any) => {
      return {
        messageId: m.id,
        conversationId: m.conversation_id,
        senderId: m.sender_id,
        senderName: m.profiles?.display_name || "Unknown",
        content: m.content || "",
        createdAt: m.created_at,
        snippet: m.content || "",
      };
    });

    return new Response(JSON.stringify(results), {
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
