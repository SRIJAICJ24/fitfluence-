-- SOCIAL LIKES SCHEMA

-- 1. POST LIKES TABLE
CREATE TABLE public.post_likes (
    user_id uuid REFERENCES public.profiles(id) NOT NULL,
    post_id uuid REFERENCES public.posts(id) NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (user_id, post_id)
);

-- 2. INDEXES
CREATE INDEX idx_post_likes_post ON public.post_likes (post_id);

-- 3. RLS POLICIES
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read likes" ON public.post_likes FOR SELECT USING (true);

CREATE POLICY "Users toggle own likes" ON public.post_likes 
    FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

-- 4. TRIGGER (Optional: Maintain like_count on posts table for performance)
-- For MVP, we can just do a count query or trigger.
-- Let's stick to simple count query or client-side optimistic for now.
-- If performance needed, add 'like_count' column to posts and trigger here.
