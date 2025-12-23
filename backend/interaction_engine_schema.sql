-- FITFLUENCE INTERACTION ENGINE - SECURITY SCHEMA
-- Section 1.1: Privacy Layering

-- 1. Private Vitals Table
-- Stores sensitive data accessible only by owner or connected buddies.
CREATE TABLE public.private_vitals (
    user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    triggers text[],
    mental_health_notes text,
    current_mood text,
    medication_info text, -- Hypothetical sensitive field
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS for private_vitals
ALTER TABLE public.private_vitals ENABLE ROW LEVEL SECURITY;

-- Policy: Owner can do anything
CREATE POLICY "Owner full access" ON public.private_vitals
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Buddy Read Access
-- "Accessible to ... a buddy with an active status in buddy_connections"
CREATE POLICY "Buddy read access" ON public.private_vitals
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.buddy_connections bc
            WHERE bc.status = 'active'
            AND (
                (bc.user_1_id = auth.uid() AND bc.user_2_id = private_vitals.user_id)
                OR
                (bc.user_2_id = auth.uid() AND bc.user_1_id = private_vitals.user_id)
            )
        )
    );

-- Section 1.2: High-Performance RLS for Messages

-- 2. Migration: Add participant_ids to messages
-- Note: In production, we'd need a backfill script. For now, we assume fresh or migration.
ALTER TABLE public.messages ADD COLUMN participant_ids uuid[] DEFAULT '{}';

-- Index for the array check (GIN index recommended for array operations)
CREATE INDEX idx_messages_participants ON public.messages USING GIN (participant_ids);

-- Update RLS for messages
DROP POLICY IF EXISTS "Users can see their own messages" ON public.messages;

CREATE POLICY "participant_check" ON public.messages 
    FOR SELECT 
    USING (auth.uid() = ANY(participant_ids));

-- Insert Policy (Sender must be in participants)
CREATE POLICY "Sender insert check" ON public.messages
    FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id 
        AND 
        auth.uid() = ANY(participant_ids)
        -- Ideally checks recipient is also in participants, but trusted client for MVP
    );

-- Section 1.4: RLS Audits

-- Buddy Matches
ALTER TABLE public.buddy_matches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "View own matches" ON public.buddy_matches
    FOR SELECT
    USING (user_a_id = auth.uid()); -- Matches are cached per user (User A perspective)

-- Buddy Requests
ALTER TABLE public.buddy_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "View involved requests" ON public.buddy_requests
    FOR ALL
    USING (requester_id = auth.uid() OR recipient_id = auth.uid());

-- User Blocks
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "View own blocks" ON public.user_blocks
    FOR SELECT
    USING (blocker_id = auth.uid());

CREATE POLICY "Manage own blocks" ON public.user_blocks
    FOR ALL
    USING (blocker_id = auth.uid());

-- Section 4: Feedback & Hardening
-- 4.1 Connection Rating Columns
ALTER TABLE public.buddy_connections ADD COLUMN rating_score INT CHECK (rating_score BETWEEN 1 AND 5);
ALTER TABLE public.buddy_connections ADD COLUMN rating_comment TEXT;
ALTER TABLE public.buddy_connections ADD COLUMN ended_at TIMESTAMPTZ;
