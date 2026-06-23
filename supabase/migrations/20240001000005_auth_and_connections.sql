-- // FILE: supabase/migrations/20240001000005_auth_and_connections.sql

-- 1. Add age and email to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS age INTEGER;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;

-- 2. Update profiles email mapping for existing rows
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS NULL;

-- 3. Update trigger public.handle_new_user()
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, username, avatar_url, age, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1) || '_' || substr(NEW.id::text, 1, 4)),
    NEW.raw_user_meta_data->>'avatar_url',
    (NEW.raw_user_meta_data->>'age')::integer,
    NEW.email
  );
  RETURN NEW;
END;
$$;

-- 4. Create connection_requests table
CREATE TABLE IF NOT EXISTS public.connection_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(sender_id, receiver_id),
  CHECK(sender_id != receiver_id)
);

-- Enable RLS on connection_requests
ALTER TABLE public.connection_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_connection_requests ON public.connection_requests
  FOR SELECT TO authenticated USING (sender_id = auth.uid() OR receiver_id = auth.uid());

CREATE POLICY insert_connection_requests ON public.connection_requests
  FOR INSERT TO authenticated WITH CHECK (sender_id = auth.uid());

CREATE POLICY update_connection_requests ON public.connection_requests
  FOR UPDATE TO authenticated USING (receiver_id = auth.uid()) WITH CHECK (receiver_id = auth.uid());

-- 5. Trigger for automated contacts creation when accepted
CREATE OR REPLACE FUNCTION public.handle_accepted_connection()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'accepted' AND OLD.status = 'pending' THEN
    -- Insert contacts for both sides
    INSERT INTO public.contacts (owner_id, contact_id)
    VALUES 
      (NEW.sender_id, NEW.receiver_id),
      (NEW.receiver_id, NEW.sender_id)
    ON CONFLICT (owner_id, contact_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_connection_accepted
  AFTER UPDATE ON public.connection_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_accepted_connection();
