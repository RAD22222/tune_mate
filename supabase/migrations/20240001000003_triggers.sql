-- // FILE: supabase/migrations/20240001000003_triggers.sql

-- ==========================================
-- TRIGGER 1: Auto-create Profile on Auth Signup
-- ==========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, username, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1) || '_' || substr(NEW.id::text, 1, 4)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ==========================================
-- TRIGGER 2: Update last message in conversation on insert
-- ==========================================
CREATE OR REPLACE FUNCTION public.update_conversation_last_message()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.conversations
  SET last_message_id = NEW.id,
      last_message_at = NEW.created_at,
      updated_at = now()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_message_inserted_last_message
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_conversation_last_message();


-- ==========================================
-- TRIGGER 3: Increment unread_count for other members
-- ==========================================
CREATE OR REPLACE FUNCTION public.increment_members_unread_count()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.conversation_members
  SET unread_count = unread_count + 1
  WHERE conversation_id = NEW.conversation_id
    AND user_id != NEW.sender_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_message_inserted_unread_count
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.increment_members_unread_count();


-- ==========================================
-- TRIGGER 4: Auto-update updated_at column
-- ==========================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER before_profile_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER before_conversation_updated
  BEFORE UPDATE ON public.conversations
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER before_message_updated_timestamp
  BEFORE UPDATE ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- ==========================================
-- TRIGGER 5: Soft-delete Messages
-- ==========================================
CREATE OR REPLACE FUNCTION public.soft_delete_message()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_deleted = true AND OLD.is_deleted = false THEN
    NEW.content = NULL;
    NEW.file_url = NULL;
    NEW.file_name = NULL;
    NEW.file_size_bytes = NULL;
    NEW.mime_type = NULL;
    NEW.thumbnail_url = NULL;
    NEW.audio_duration_ms = NULL;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER before_message_updated_soft_delete
  BEFORE UPDATE ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.soft_delete_message();
