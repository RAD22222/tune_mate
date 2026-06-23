-- // FILE: supabase/migrations/20240001000002_indexes.sql

-- Messages Indexes
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created_at 
  ON public.messages(conversation_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_sender_id 
  ON public.messages(sender_id);

CREATE INDEX IF NOT EXISTS idx_messages_reply_to_id 
  ON public.messages(reply_to_id);

-- Conversation Members Indexes
CREATE INDEX IF NOT EXISTS idx_conversation_members_user_id 
  ON public.conversation_members(user_id);

CREATE INDEX IF NOT EXISTS idx_conversation_members_conversation_id 
  ON public.conversation_members(conversation_id);

-- Calls Indexes
CREATE INDEX IF NOT EXISTS idx_calls_caller_id_created_at 
  ON public.calls(caller_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_calls_callee_id_created_at 
  ON public.calls(callee_id, created_at DESC);

-- Contacts Indexes
CREATE INDEX IF NOT EXISTS idx_contacts_owner_id 
  ON public.contacts(owner_id);

-- Profiles Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_username 
  ON public.profiles(username);

-- Full-text Search Index on messages content
CREATE INDEX IF NOT EXISTS idx_messages_fts 
  ON public.messages USING GIN (to_tsvector('english', coalesce(content, '')));

CREATE INDEX IF NOT EXISTS idx_messages_fts_direct 
  ON public.messages USING GIN (to_tsvector('english', content));
