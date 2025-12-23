-- Phase 4: Monetization & Pro Features Schema

-- SUBSCRIPTIONS
-- Tracks user subscription status and tier
create type subscription_tier as enum ('free', 'pro', 'elite');
create type subscription_status as enum ('active', 'canceled', 'expired', 'past_due');

create table public.subscriptions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  tier subscription_tier default 'free',
  status subscription_status default 'active',
  current_period_start timestamp with time zone default now(),
  current_period_end timestamp with time zone,
  cancel_at_period_end boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- RLS for subscriptions
alter table public.subscriptions enable row level security;

create policy "Users can view their own subscription"
  on public.subscriptions for select
  using (auth.uid() = user_id);

create policy "Users can update their own subscription (Mock)"
  on public.subscriptions for update
  using (auth.uid() = user_id);

create policy "Users can insert their own subscription (Mock)"
  on public.subscriptions for insert
  with check (auth.uid() = user_id);


-- ANALYTICS (Creator Tools)
-- Aggregated daily stats for creators
create table public.analytics_daily (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade not null,
  date date default current_date,
  profile_views int default 0,
  post_reach int default 0,
  interactions int default 0,
  created_at timestamp with time zone default now(),
  unique(user_id, date) -- One record per user per day
);

-- RLS for analytics
alter table public.analytics_daily enable row level security;

create policy "Users can view their own analytics"
  on public.analytics_daily for select
  using (auth.uid() = user_id);

-- In a real app, this would be updated by reliable backend triggers, 
-- but for this prototype, we might allow the client to increment (not secure, but functional for demo)
create policy "Users can update their own analytics"
  on public.analytics_daily for update
  using (auth.uid() = user_id);

create policy "Users can insert their own analytics"
  on public.analytics_daily for insert
  with check (auth.uid() = user_id);
