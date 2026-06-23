// FILE: supabase/functions/upload-media/index.ts

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
    const adminClient = createAdminClient();

    // Parse multipart form
    const formData = await req.formData();
    const file = formData.get("file") as File;
    const conversationId = formData.get("conversationId") as string;
    const messageType = formData.get("messageType") as string; // 'image', 'video', 'audio', 'file'

    if (!file || !conversationId || !messageType) {
      return new Response(JSON.stringify({ error: "Missing required form fields" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Validate conversation membership
    const { data: member, error: memberErr } = await adminClient
      .from("conversation_members")
      .select("id")
      .eq("conversation_id", conversationId)
      .eq("user_id", userId)
      .maybeSingle();

    if (memberErr || !member) {
      return new Response(JSON.stringify({ error: "Unauthorized conversation access" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Size and Mime-type validation
    const sizeBytes = file.size;
    const mimeType = file.type;
    const originalName = file.name;

    if (messageType === "audio" && sizeBytes > 10 * 1024 * 1024) {
      throw new Error("Audio voice-note exceeds 10MB limit");
    }
    if (sizeBytes > 50 * 1024 * 1024) {
      throw new Error("File size exceeds 50MB limit");
    }

    // 3. Determine bucket
    let bucket = "files";
    if (messageType === "audio") {
      bucket = "voice-notes";
    } else if (messageType === "image" || messageType === "video") {
      bucket = "media";
    }

    // 4. Generate storage path: {userId}/{year}/{month}/{uuid}.{ext}
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const uuid = crypto.randomUUID();
    const ext = originalName.split(".").pop() || "";
    const path = `${userId}/${year}/${month}/${uuid}.${ext}`;

    // 5. Upload to Storage
    const fileBuffer = await file.arrayBuffer();
    const { error: uploadErr } = await adminClient.storage
      .from(bucket)
      .upload(path, fileBuffer, {
        contentType: mimeType,
        duplex: "half",
      });

    if (uploadErr) throw uploadErr;

    // 6. Get Public URL (Avatars is public, others can use public path identifier to fetch signed urls later)
    const { data: { publicUrl } } = adminClient.storage
      .from(bucket)
      .getPublicUrl(path);

    // 7. Insert to files table
    const { data: fileRow, error: fileErr } = await adminClient
      .from("files")
      .insert({
        uploaded_by: userId,
        bucket,
        path,
        original_name: originalName,
        mime_type: mimeType,
        size_bytes: sizeBytes,
        thumbnail_path: null,
      })
      .select()
      .single();

    if (fileErr) throw fileErr;

    return new Response(
      JSON.stringify({
        fileUrl: publicUrl,
        thumbnailUrl: null,
        fileId: fileRow.id,
        mimeType,
        sizeBytes,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
