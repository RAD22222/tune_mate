// FILE: supabase/functions/create-conversation/index.ts

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
    const { type, name, memberIds, avatarUrl } = await req.json();

    if (type !== "direct" && type !== "group") {
      return new Response(JSON.stringify({ error: "Invalid conversation type" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!memberIds || !Array.isArray(memberIds) || memberIds.length === 0) {
      return new Response(JSON.stringify({ error: "At least one member is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const adminClient = createAdminClient();

    // 1. Enforce direct chat uniqueness check
    if (type === "direct") {
      if (memberIds.length !== 1) {
        return new Response(JSON.stringify({ error: "Direct conversations require exactly 1 target user" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      const otherUserId = memberIds[0];

      // Query if direct chat exists
      const { data: myMembers, error: myMembersErr } = await adminClient
        .from("conversation_members")
        .select("conversation_id")
        .eq("user_id", userId);

      if (myMembersErr) throw myMembersErr;

      if (myMembers && myMembers.length > 0) {
        const myConvIds = myMembers.map((m) => m.conversation_id);

        const { data: existingMember, error: existErr } = await adminClient
          .from("conversation_members")
          .select("conversation_id, conversations!inner(type)")
          .eq("user_id", otherUserId)
          .in("conversation_id", myConvIds)
          .eq("conversations.type", "direct")
          .maybeSingle();

        if (existErr) throw existErr;

        if (existingMember) {
          // Direct conversation already exists
          return new Response(JSON.stringify({ conversationId: existingMember.conversation_id, isNew: false }), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
      }
    }

    // 2. Validate group name requirement
    if (type === "group" && (!name || name.trim().length === 0)) {
      return new Response(JSON.stringify({ error: "Group name is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Create conversation row
    const { data: conversation, error: convErr } = await adminClient
      .from("conversations")
      .insert({
        type,
        name: type === "group" ? name : null,
        avatar_url: avatarUrl || null,
        created_by: userId,
      })
      .select()
      .single();

    if (convErr) throw convErr;
    const conversationId = conversation.id;

    // 4. Insert member mappings
    const membersList = [];
    
    // Add owner/creator (admin role)
    membersList.push({
      conversation_id: conversationId,
      user_id: userId,
      role: "admin",
    });

    // Add remaining users
    for (const memberId of memberIds) {
      if (memberId !== userId) {
        membersList.push({
          conversation_id: conversationId,
          user_id: memberId,
          role: type === "group" ? "member" : "admin",
        });
      }
    }

    const { error: memsErr } = await adminClient
      .from("conversation_members")
      .insert(membersList);

    if (memsErr) throw memsErr;

    return new Response(JSON.stringify({ conversationId, isNew: true }), {
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
