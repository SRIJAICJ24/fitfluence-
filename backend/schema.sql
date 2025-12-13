-- FITFLUENCE PHASE 1 - COMPLETE DATABASE SCHEMA
-- Based on Technical Specification Section 5

-- 1. PROFILES
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  phone TEXT UNIQUE,
  username TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
  date_of_birth DATE,
  location_city TEXT,
  location_lat FLOAT,
  location_lon FLOAT,
  fitness_level TEXT CHECK (fitness_level IN ('Beginner', 'Intermediate', 'Advanced', 'Elite')),
  fitness_goals TEXT[] DEFAULT ARRAY[]::TEXT[], -- ['Strength', 'Hypertrophy', 'Endurance', 'Weight Loss', 'Flexibility']
  gym_id UUID, -- References gyms(id) (defined below)
  mental_health_comfort TEXT CHECK (mental_health_comfort IN ('Very Open', 'Moderate', 'Private')),
  available_days TEXT[] DEFAULT ARRAY[]::TEXT[], -- ['Monday', 'Tuesday', ...]
  available_start_time TIME,
  available_end_time TIME,
  bio_verified BOOLEAN DEFAULT FALSE,
  photos_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_banned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_profile_update TIMESTAMPTZ DEFAULT NOW()
);

-- 2. GYMS
CREATE TABLE gyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT,
  country TEXT DEFAULT 'India',
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  address TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  amenities TEXT[] DEFAULT ARRAY[]::TEXT[],
  facilities TEXT[] DEFAULT ARRAY[]::TEXT[],
  rating FLOAT DEFAULT 0,
  review_count INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  operating_hours_open TIME DEFAULT '05:00:00',
  operating_hours_close TIME DEFAULT '22:00:00',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key back to profiles
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_gym FOREIGN KEY (gym_id) REFERENCES gyms(id);

-- 3. GYM REVIEWS
CREATE TABLE gym_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  verified_visitor BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BUDDY CONNECTIONS
CREATE TABLE buddy_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
  match_score INT DEFAULT 0,
  match_metadata JSONB DEFAULT '{}',
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  rejected_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_connection UNIQUE (sender_id, recipient_id)
);

-- 5. CONVERSATIONS
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  user_2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  connection_id UUID REFERENCES buddy_connections(id) ON DELETE CASCADE,
  last_message_id UUID,
  last_message_text TEXT,
  last_message_at TIMESTAMPTZ,
  user_1_unread_count INT DEFAULT 0,
  user_2_unread_count INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_conversation UNIQUE (user_1_id, user_2_id)
);

-- 6. MESSAGES
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'video', 'emoji')),
  media_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_by CHAR, -- 'S'ender or 'R'ecipient or 'B'oth
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. BLOCKS
CREATE TABLE blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason TEXT,
  blocked_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_block UNIQUE (blocker_id, blocked_id)
);

-- 8. REPORTS
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reported_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  report_category TEXT NOT NULL CHECK (report_category IN ('Harassment', 'Inappropriate Content', 'Fake Profile', 'Safety Concern', 'Other')),
  report_text TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
  resolution_notes TEXT,
  reported_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. USER PRESENCE
CREATE TABLE users_presence (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  is_online BOOLEAN DEFAULT FALSE,
  last_active TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. EMBEDDINGS (for matching)
CREATE TABLE embeddings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  goals_embedding FLOAT8[] DEFAULT ARRAY[]::FLOAT8[],
  fitness_level_embedding FLOAT8[] DEFAULT ARRAY[]::FLOAT8[],
  schedule_embedding FLOAT8[] DEFAULT ARRAY[]::FLOAT8[],
  location_lat FLOAT,
  location_lon FLOAT,
  mental_health_embedding FLOAT8[] DEFAULT ARRAY[]::FLOAT8[],
  last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ANALYTICS
CREATE TABLE analytics (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  event_data JSONB,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  session_id TEXT
);

-- INDEXES
CREATE INDEX idx_profiles_gym_id ON profiles(gym_id);
CREATE INDEX idx_profiles_fitness_level ON profiles(fitness_level);
CREATE INDEX idx_profiles_location ON profiles(location_lat, location_lon);
CREATE INDEX idx_gyms_location ON gyms(latitude, longitude);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- RLS POLICIES (Basic Examples)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are visible to everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see their own messages" ON messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = recipient_id);
