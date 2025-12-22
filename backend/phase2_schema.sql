-- FITFLUENCE PHASE 2 SCHEMA (VERSION 2.0)
-- -----------------------------------------------------------------------------
-- This script aligns the database with the Master Agent Prompt v2.0.
-- It preserves 'profiles' and 'gyms' but RECREATES social tables to ensure exact spec match.
--
-- EXECUTION INSTRUCTIONS:
-- 1. Run this in Supabase SQL Editor.
-- 2. If you have existing chat/connection data, it WILL BE LOST. (Profiles/Gyms are safe).
-- -----------------------------------------------------------------------------

-- 1. CLEANUP OLD TABLES (To ensure clean state for new spec)
DROP TABLE IF EXISTS safety_reports CASCADE; -- Renamed from reports
DROP TABLE IF EXISTS reports CASCADE;        -- Old name
DROP TABLE IF EXISTS user_blocks CASCADE;    -- Renamed from blocks
DROP TABLE IF EXISTS blocks CASCADE;         -- Old name
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS buddy_connections CASCADE;
DROP TABLE IF EXISTS buddy_requests CASCADE; -- New table
DROP TABLE IF EXISTS buddy_matches CASCADE;  -- New table

-- -----------------------------------------------------------------------------
-- 2. NEW TABLES (EXACT SPEC MATCH)
-- -----------------------------------------------------------------------------

-- Table 1: buddy_matches (Cache Layer)
CREATE TABLE buddy_matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  user_b_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  match_score FLOAT NOT NULL CHECK (match_score >= 0 AND match_score <= 100),
  match_details JSONB,  -- e.g. {"jaccard_goals": 0.33, "schedule_overlap": 1.0}
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_a_id, user_b_id)
);
CREATE INDEX idx_buddy_matches_user_a ON buddy_matches(user_a_id);
CREATE INDEX idx_buddy_matches_user_b ON buddy_matches(user_b_id);
CREATE INDEX idx_buddy_matches_score ON buddy_matches(match_score DESC);

-- Table 2: buddy_requests (Explicit Requests)
CREATE TABLE buddy_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
  created_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '14 days'),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (requester_id, recipient_id)
);
CREATE INDEX idx_buddy_requests_recipient ON buddy_requests(recipient_id);
CREATE INDEX idx_buddy_requests_status ON buddy_requests(status);

-- Table 3: buddy_connections (Confirmed Partnerships)
CREATE TABLE buddy_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  user_2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'paused', 'ended', 'blocked')),
  started_at TIMESTAMPTZ DEFAULT now(),
  ended_at TIMESTAMPTZ,
  rating FLOAT CHECK (rating >= 1 AND rating <= 5),
  feedback TEXT,
  UNIQUE (user_1_id, user_2_id)
);
CREATE INDEX idx_buddy_connections_user1 ON buddy_connections(user_1_id);
CREATE INDEX idx_buddy_connections_user2 ON buddy_connections(user_2_id);
CREATE INDEX idx_buddy_connections_status ON buddy_connections(status);

-- Table 4: conversations (Chat Threads)
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  user_2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  last_message_preview TEXT,
  last_message_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_1_id, user_2_id)
);
CREATE INDEX idx_conversations_user1 ON conversations(user_1_id);
CREATE INDEX idx_conversations_user2 ON conversations(user_2_id);
CREATE INDEX idx_conversations_last_msg ON conversations(last_message_at DESC);

-- Table 5: messages (Chat Messages)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_messages_conv_created ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_is_read ON messages(is_read);

-- Table 6: safety_reports (Abuse Reports)
CREATE TABLE safety_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reported_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  report_type TEXT NOT NULL
    CHECK (report_type IN ('harassment', 'inappropriate', 'fake', 'spam', 'other')),
  message_id UUID REFERENCES messages(id),
  description TEXT,
  evidence_urls TEXT[],
  status TEXT NOT NULL DEFAULT 'submitted'
    CHECK (status IN ('submitted', 'under_review', 'resolved', 'rejected')),
  moderator_id UUID REFERENCES profiles(id),
  action_taken TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  reviewed_at TIMESTAMPTZ
);
CREATE INDEX idx_safety_reports_reported ON safety_reports(reported_user_id);
CREATE INDEX idx_safety_reports_status ON safety_reports(status);

-- Table 7: user_blocks (Blocked Users)
CREATE TABLE user_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (blocker_id, blocked_user_id)
);
CREATE INDEX idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_user_blocks_blocked ON user_blocks(blocked_user_id);

-- -----------------------------------------------------------------------------
-- 3. CRITICAL PERFORMANCE INDEXES (PROFILES)
-- -----------------------------------------------------------------------------
-- These ensure the matching algorithm (Stage 1 & 2) is fast.
-- Note: 'gym_id' index likely exists, but 'IF NOT EXISTS' handles it.
-- GIN indexes assume 'goals' and 'available_days' (schedule) are text[].

CREATE INDEX IF NOT EXISTS idx_profiles_gym_id ON profiles(gym_id);
CREATE INDEX IF NOT EXISTS idx_profiles_goals_gin ON profiles USING GIN (fitness_goals);  -- Matching column name
CREATE INDEX IF NOT EXISTS idx_profiles_schedule_gin ON profiles USING GIN (available_days); -- Matching column name
-- Add last_active_at if not present
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMPTZ DEFAULT now();
CREATE INDEX IF NOT EXISTS idx_profiles_last_active ON profiles(last_active_at DESC);

-- -----------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS) - ZERO TRUST
-- -----------------------------------------------------------------------------

-- Enable RLS on all tables
ALTER TABLE buddy_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE buddy_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE buddy_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE safety_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;

-- Buddy Matches: Only visible to owner
CREATE POLICY "Users view own matches" ON buddy_matches
  FOR SELECT USING (auth.uid() = user_a_id);

-- Buddy Requests: Visible to sender and recipient
CREATE POLICY "Users view requests involved in" ON buddy_requests
  FOR SELECT USING (auth.uid() = requester_id OR auth.uid() = recipient_id);

CREATE POLICY "Users insert requests" ON buddy_requests
  FOR INSERT WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "Recipients update requests" ON buddy_requests
  FOR UPDATE USING (auth.uid() = recipient_id);

-- Buddy Connections: Visible to partners
CREATE POLICY "Users view own connections" ON buddy_connections
  FOR SELECT USING (auth.uid() = user_1_id OR auth.uid() = user_2_id);

-- Conversations: Visible to participants
CREATE POLICY "Users view own conversations" ON conversations
  FOR SELECT USING (auth.uid() = user_1_id OR auth.uid() = user_2_id);

-- Messages: Visible to participants (via conversation join check or direct ID check)
-- Optimal RLS often duplicates sender/receiver IDs on message for performance (done in schema)
CREATE POLICY "Users view own messages" ON messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users send messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);
-- (Additional constraints can verify conversation membership if needed)

-- User Blocks: Visible to blocker
CREATE POLICY "Users view blocks they created" ON user_blocks
  FOR SELECT USING (auth.uid() = blocker_id);

CREATE POLICY "Users can block others" ON user_blocks
  FOR INSERT WITH CHECK (auth.uid() = blocker_id);

-- Safety Reports: Visible to reporter (and admins, not defined here)
CREATE POLICY "Users view own reports" ON safety_reports
  FOR SELECT USING (auth.uid() = reporter_id);

CREATE POLICY "Users create reports" ON safety_reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);
