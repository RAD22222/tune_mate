-- // FILE: supabase/migrations/20240001000004_storage_buckets.sql

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- INSERT STORAGE BUCKETS
-- ==========================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]),
  ('media', 'media', false, 52428800, ARRAY['image/*', 'video/*']::text[]),
  ('files', 'files', false, 52428800, NULL),
  ('voice-notes', 'voice-notes', false, 10485760, ARRAY['audio/*']::text[])
ON CONFLICT (id) DO UPDATE 
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;


-- ==========================================
-- AVATARS POLICIES
-- ==========================================
CREATE POLICY select_avatars ON storage.objects 
  FOR SELECT TO authenticated USING (bucket_id = 'avatars');

CREATE POLICY insert_avatars ON storage.objects 
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'avatars' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY update_avatars ON storage.objects 
  FOR UPDATE TO authenticated USING (
    bucket_id = 'avatars' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY delete_avatars ON storage.objects 
  FOR DELETE TO authenticated USING (
    bucket_id = 'avatars' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );


-- ==========================================
-- PRIVATE OBJECTS POLICIES (media, files, voice-notes)
-- ==========================================
CREATE POLICY read_private_objects ON storage.objects 
  FOR SELECT TO authenticated USING (
    bucket_id IN ('media', 'files', 'voice-notes') AND (
      owner = auth.uid() OR
      EXISTS (
        SELECT 1 FROM public.files f
        JOIN public.messages m ON f.message_id = m.id
        JOIN public.conversation_members cm ON m.conversation_id = cm.conversation_id
        WHERE f.bucket = bucket_id AND f.path = name AND cm.user_id = auth.uid()
      )
    )
  );

CREATE POLICY insert_private_objects ON storage.objects 
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id IN ('media', 'files', 'voice-notes') AND 
    owner = auth.uid()
  );
