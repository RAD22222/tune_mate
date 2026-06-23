-- // FILE: supabase/migrations/20240001000001_rls_policies.sql

-- ==========================================
-- PROFILES POLICIES
-- ==========================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_profiles ON public.profiles
  FOR SELECT TO authenticated USING (true);

CREATE POLICY insert_profiles ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

CREATE POLICY update_profiles ON public.profiles
  FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());

CREATE POLICY delete_profiles ON public.profiles
  FOR DELETE TO authenticated USING (id = auth.uid());


-- ==========================================
-- CONTACTS POLICIES
-- ==========================================
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_contacts ON public.contacts
  FOR SELECT TO authenticated USING (owner_id = auth.uid());

CREATE POLICY insert_contacts ON public.contacts
  FOR INSERT TO authenticated WITH CHECK (owner_id = auth.uid());

CREATE POLICY update_contacts ON public.contacts
  FOR UPDATE TO authenticated USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

CREATE POLICY delete_contacts ON public.contacts
  FOR DELETE TO authenticated USING (owner_id = auth.uid());


-- ==========================================
-- CONVERSATIONS POLICIES
-- ==========================================
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_conversations ON public.conversations
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.conversation_members
      WHERE conversation_id = public.conversations.id AND user_id = auth.uid()
    )
  );

CREATE POLICY insert_conversations ON public.conversations
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY update_conversations ON public.conversations
  FOR UPDATE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.conversation_members
      WHERE conversation_id = public.conversations.id AND user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY delete_conversations ON public.conversations
  FOR DELETE TO authenticated USING (created_by = auth.uid());


-- ==========================================
-- CONVERSATION MEMBERS POLICIES
-- ==========================================
ALTER TABLE public.conversation_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_members ON public.conversation_members
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.conversation_members m
      WHERE m.conversation_id = public.conversation_members.conversation_id AND m.user_id = auth.uid()
    )
  );

CREATE POLICY insert_members ON public.conversation_members
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.conversation_members
      WHERE conversation_id = public.conversation_members.conversation_id AND user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY update_members ON public.conversation_members
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

CREATE POLICY delete_members ON public.conversation_members
  FOR DELETE TO authenticated USING (
    user_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM public.conversation_members
      WHERE conversation_id = public.conversation_members.conversation_id AND user_id = auth.uid() AND role = 'admin'
    )
  );


-- ==========================================
-- MESSAGES POLICIES
-- ==========================================
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_messages ON public.messages
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.conversation_members
      WHERE conversation_id = public.messages.conversation_id AND user_id = auth.uid()
    )
  );

CREATE POLICY insert_messages ON public.messages
  FOR INSERT TO authenticated WITH CHECK (
    sender_id = auth.uid() AND 
    EXISTS (
      SELECT 1 FROM public.conversation_members
      WHERE conversation_id = public.messages.conversation_id AND user_id = auth.uid()
    )
  );

CREATE POLICY update_messages ON public.messages
  FOR UPDATE TO authenticated USING (sender_id = auth.uid()) WITH CHECK (sender_id = auth.uid());

CREATE POLICY delete_messages ON public.messages
  FOR DELETE TO authenticated USING (sender_id = auth.uid());


-- ==========================================
-- MESSAGE REACTIONS POLICIES
-- ==========================================
ALTER TABLE public.message_reactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_reactions ON public.message_reactions
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.conversation_members cm
      JOIN public.messages m ON cm.conversation_id = m.conversation_id
      WHERE m.id = public.message_reactions.message_id AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY insert_reactions ON public.message_reactions
  FOR INSERT TO authenticated WITH CHECK (
    user_id = auth.uid() AND 
    EXISTS (
      SELECT 1 FROM public.conversation_members cm
      JOIN public.messages m ON cm.conversation_id = m.conversation_id
      WHERE m.id = public.message_reactions.message_id AND cm.user_id = auth.uid()
    )
  );

CREATE POLICY delete_reactions ON public.message_reactions
  FOR DELETE TO authenticated USING (user_id = auth.uid());


-- ==========================================
-- CALLS POLICIES
-- ==========================================
ALTER TABLE public.calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_calls ON public.calls
  FOR SELECT TO authenticated USING (caller_id = auth.uid() OR callee_id = auth.uid());

CREATE POLICY insert_calls ON public.calls
  FOR INSERT TO authenticated WITH CHECK (caller_id = auth.uid());

CREATE POLICY update_calls ON public.calls
  FOR UPDATE TO authenticated USING (caller_id = auth.uid() OR callee_id = auth.uid())
  WITH CHECK (caller_id = auth.uid() OR callee_id = auth.uid());


-- ==========================================
-- FILES POLICIES
-- ==========================================
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_files ON public.files
  FOR SELECT TO authenticated USING (
    uploaded_by = auth.uid() OR 
    (
      message_id IS NOT NULL AND 
      EXISTS (
        SELECT 1 FROM public.conversation_members cm
        JOIN public.messages m ON cm.conversation_id = m.conversation_id
        WHERE m.id = public.files.message_id AND cm.user_id = auth.uid()
      )
    )
  );

CREATE POLICY insert_files ON public.files
  FOR INSERT TO authenticated WITH CHECK (uploaded_by = auth.uid());
