-- INTERACTION ENGINE - SECTION 2: SMART DISCOVERY ENGINE
-- 2.1 Stage 1: The Hard Filters (SQL Level)

CREATE OR REPLACE FUNCTION get_match_candidates(
    current_user_id uuid,
    current_gym_id uuid,
    preferred_gender text, -- 'Male', 'Female', 'Any'
    limit_count int DEFAULT 50
)
RETURNS TABLE (
    id uuid,
    first_name text,
    last_name text,
    gym_id uuid,
    gender text,
    fitness_goals text[],
    available_days text[],
    fitness_level text,
    user_dob date,
    location_city text
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.first_name,
        p.last_name,
        p.gym_id,
        p.gender,
        p.fitness_goals,
        p.available_days,
        p.fitness_level,
        p.date_of_birth,
        p.location_city
    FROM profiles p
    WHERE 
        p.id != current_user_id -- Exclude self
        AND p.gym_id = current_gym_id -- Hard Filter: Same Gym
        AND p.is_active = true
        AND (
            preferred_gender = 'Any' 
            OR p.gender = preferred_gender
        )
        -- Hard Filter: Block Check (Exclusion)
        AND NOT EXISTS (
            SELECT 1 FROM user_blocks ub
            WHERE (ub.blocker_id = current_user_id AND ub.blocked_id = p.id)
            OR (ub.blocker_id = p.id AND ub.blocked_id = current_user_id)
        )
        -- Optimization: Exclude existing connections or pending requests?
        -- Master prompt says "Candidate IDs", usually means new people.
        AND NOT EXISTS (
             SELECT 1 FROM buddy_connections bc
             WHERE (bc.sender_id = current_user_id AND bc.recipient_id = p.id)
             OR (bc.recipient_id = current_user_id AND bc.sender_id = p.id)
        )
    LIMIT limit_count;
END;
$$;
