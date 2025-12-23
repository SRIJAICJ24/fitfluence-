-- PHASE 3: SOCIAL EVOLUTION SCHEMA

-- 1. FOLLOWERS (Social Graph)
CREATE TABLE public.followers (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    follower_id uuid REFERENCES public.profiles(id) NOT NULL,
    following_id uuid REFERENCES public.profiles(id) NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(follower_id, following_id)
);

-- 2. STREAKS (Gamification)
CREATE TABLE public.user_streaks (
    user_id uuid REFERENCES public.profiles(id) PRIMARY KEY,
    current_streak int DEFAULT 0,
    best_streak int DEFAULT 0,
    last_activity_date timestamp with time zone,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. FLEX STORIES (Ephemeral Content)
-- Logic: expires_at should be set to NOW() + 24 hours on client or server trigger
CREATE TABLE public.flex_stories (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) NOT NULL,
    media_url text NOT NULL,
    streak_type text CHECK (streak_type IN ('gym', 'nutrition', 'mindfulness', 'other')),
    streak_count int DEFAULT 0, -- Snapshot of streak at time of posting
    gym_id text REFERENCES public.gyms(id), -- If tagged/verified
    is_verified boolean DEFAULT false, -- Geofenced check result
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. POSTS (Permanent Feed)
CREATE TABLE public.posts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) NOT NULL,
    caption text,
    media_urls text[] NOT NULL, -- Array of URLs
    hashtags jsonb DEFAULT '[]'::jsonb, -- Store hashtags for high-speed GIN search
    mentions uuid[] DEFAULT '{}', -- Array of user IDs mentioned
    is_pr boolean DEFAULT false, -- Personal Record flag (Prismatic Border)
    location_name text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. PULSES (Short Form Video)
CREATE TABLE public.pulses (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    creator_id uuid REFERENCES public.profiles(id) NOT NULL,
    video_url text NOT NULL,
    thumbnail_url text, -- Poster image
    category text CHECK (category IN ('motivation', 'tips', 'form', 'nutrition', 'lifestyle')),
    view_count bigint DEFAULT 0,
    share_count bigint DEFAULT 0,
    gym_id text REFERENCES public.gyms(id), -- For "My Gym" filter
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. INDEXING (Performance)
-- GIN Index for JSONB hashtags to enable <300ms search
CREATE INDEX idx_posts_hashtags ON public.posts USING GIN (hashtags);

-- Standard indexes for Feed lookups
CREATE INDEX idx_flex_user_expires ON public.flex_stories (user_id, expires_at);
CREATE INDEX idx_posts_user_created ON public.posts (user_id, created_at DESC);
CREATE INDEX idx_pulses_gym_created ON public.pulses (gym_id, created_at DESC);
CREATE INDEX idx_pulses_category ON public.pulses (category);

-- 7. RLS POLICIES (Security)
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flex_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pulses ENABLE ROW LEVEL SECURITY;

-- Simple Policies (Broad read, Owner write)
CREATE POLICY "Public read followers" ON public.followers FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON public.followers FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.followers FOR DELETE USING (auth.uid() = follower_id);

CREATE POLICY "Public read flex" ON public.flex_stories FOR SELECT USING (expires_at > now());
CREATE POLICY "Users create flex" ON public.flex_stories FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Public read posts" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Users create posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Public read pulses" ON public.pulses FOR SELECT USING (true);
CREATE POLICY "Users create pulses" ON public.pulses FOR INSERT WITH CHECK (auth.uid() = creator_id);
