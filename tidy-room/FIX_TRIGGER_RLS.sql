-- =====================================================
-- FIX TRIGGER RLS ISSUE
-- Run this in Supabase SQL Editor
-- =====================================================
-- The create_child_room trigger needs SECURITY DEFINER to bypass RLS

-- Step 1: Drop and recreate the function with SECURITY DEFINER
CREATE OR REPLACE FUNCTION create_child_room()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER  -- This allows the function to bypass RLS
SET search_path = public
AS $$
DECLARE
    default_theme_id UUID;
BEGIN
    -- Get default theme
    SELECT id INTO default_theme_id FROM public.tidy_themes WHERE is_default = TRUE LIMIT 1;
    
    -- Create room for the new child
    INSERT INTO public.tidy_rooms (child_id, theme_id, cleanliness_score, zone_bed, zone_floor, zone_desk, zone_closet, zone_general)
    VALUES (NEW.id, default_theme_id, 50, 50, 50, 50, 50, 50);
    
    -- Create streak record for the new child
    INSERT INTO public.tidy_streaks (child_id, current_streak, longest_streak)
    VALUES (NEW.id, 0, 0);
    
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail the child creation
    RAISE WARNING 'Error in create_child_room trigger: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- Step 2: Ensure the trigger exists
DROP TRIGGER IF EXISTS trigger_create_child_room ON public.tidy_children;
CREATE TRIGGER trigger_create_child_room
    AFTER INSERT ON public.tidy_children
    FOR EACH ROW
    EXECUTE FUNCTION create_child_room();

-- Step 3: Verify the function has SECURITY DEFINER
SELECT 
    proname as function_name,
    prosecdef as is_security_definer
FROM pg_proc 
WHERE proname = 'create_child_room';

-- =====================================================
-- DONE! The trigger should now work with RLS enabled.
-- =====================================================
