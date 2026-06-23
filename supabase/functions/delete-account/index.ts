// FILE: supabase/functions/delete-account/index.ts

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
    const { confirmation } = await req.json();

    if (confirmation !== "DELETE MY ACCOUNT") {
      return new Response(JSON.stringify({ error: "Confirmation text does not match" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const adminClient = createAdminClient();

    // 1. Query files uploaded by user to delete them from Storage
    const { data: userFiles, error: filesQueryErr } = await adminClient
      .from("files")
      .select("bucket, path")
      .eq("uploaded_by", userId);

    if (filesQueryErr) throw filesQueryErr;

    // 2. Perform files deletion from Supabase Storage buckets
    if (userFiles && userFiles.length > 0) {
      const bucketPaths: Record<string, string[]> = {};
      for (const file of userFiles) {
        if (!bucketPaths[file.bucket]) {
          bucketPaths[file.bucket] = [];
        }
        bucketPaths[file.bucket].push(file.path);
      }

      for (const bucket of Object.keys(bucketPaths)) {
        const paths = bucketPaths[bucket];
        const { error: removeErr } = await adminClient.storage
          .from(bucket)
          .remove(paths);
        if (removeErr) {
          console.error(`Failed to remove files in bucket ${bucket}:`, removeErr);
        }
      }
    }

    // 3. Delete user's avatar file if exists
    // Path pattern for avatar: {userId}/avatar.{ext}
    // We can list files in the avatars bucket starting with user's ID
    const { data: avatarList } = await adminClient.storage
      .from("avatars")
      .list(userId);

    if (avatarList && avatarList.length > 0) {
      const avatarPaths = avatarList.map((file) => `${userId}/${file.name}`);
      await adminClient.storage.from("avatars").remove(avatarPaths);
    }

    // 4. Delete the Auth User.
    // Due to the ON DELETE CASCADE constraint on profiles referencing auth.users,
    // this will delete public.profiles, public.contacts, public.conversation_members,
    // and clean up all dependent public database rows automatically.
    const { error: deleteUserErr } = await adminClient.auth.admin.deleteUser(userId);
    if (deleteUserErr) throw deleteUserErr;

    return new Response(JSON.stringify({ message: "Account deleted successfully" }), {
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
