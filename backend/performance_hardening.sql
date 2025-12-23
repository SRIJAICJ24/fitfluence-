-- INTERACTION ENGINE - SECTION 4: PERFORMANCE & HARDENING
-- 4.2 Performance: GIN Indexes & Cache Invalidation

-- GIN Indexes for Array Columns (Faster Jaccard/Overlap queries)
CREATE INDEX IF NOT EXISTS idx_profiles_goals ON profiles USING GIN (fitness_goals);
CREATE INDEX IF NOT EXISTS idx_profiles_schedule ON profiles USING GIN (available_days);
CREATE INDEX IF NOT EXISTS idx_profiles_mental ON profiles USING GIN (mental_health_comfort); -- If array, currently text but useful if filtered

-- Cache Invalidation Trigger
-- Purpose: Force algorithm recalculation if a user's key matching data changes.
CREATE OR REPLACE FUNCTION invalidate_match_cache() RETURNS TRIGGER AS $$
BEGIN
    -- If critical fields change, delete related matches to force recalc on next discovery load
    IF OLD.gym_id IS DISTINCT FROM NEW.gym_id 
       OR OLD.fitness_goals IS DISTINCT FROM NEW.fitness_goals 
       OR OLD.available_days IS DISTINCT FROM NEW.available_days 
    THEN
        DELETE FROM buddy_matches WHERE user_a_id = NEW.id OR user_b_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_match_cache ON profiles;

CREATE TRIGGER trigger_update_match_cache
AFTER UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION invalidate_match_cache();
