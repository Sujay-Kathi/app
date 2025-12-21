-- =====================================================
-- FIX CHILD LOGIN - Allow unauthenticated users to see children for login
-- Run this in Supabase SQL Editor
-- =====================================================

-- Create a SECURITY DEFINER function that returns children for login purposes
-- This bypasses RLS so unauthenticated users can see children to select

CREATE OR REPLACE FUNCTION get_children_for_login()
RETURNS TABLE (
    id UUID,
    name TEXT,
    avatar_emoji TEXT,
    family_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.avatar_emoji,
        c.family_id
    FROM public.tidy_children c
    ORDER BY c.name;
END;
$$;

-- Grant execute to public (including unauthenticated users)
GRANT EXECUTE ON FUNCTION get_children_for_login() TO anon;
GRANT EXECUTE ON FUNCTION get_children_for_login() TO authenticated;

-- Create a function to verify child PIN (also SECURITY DEFINER)
CREATE OR REPLACE FUNCTION verify_child_pin(p_child_id UUID, p_pin TEXT)
RETURNS TABLE (
    id UUID,
    name TEXT,
    avatar_emoji TEXT,
    family_id UUID,
    current_level INT,
    total_points INT,
    available_points INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.avatar_emoji,
        c.family_id,
        c.current_level,
        c.total_points,
        c.available_points
    FROM public.tidy_children c
    WHERE c.id = p_child_id AND c.pin_code = p_pin;
END;
$$;

-- Grant execute to public
GRANT EXECUTE ON FUNCTION verify_child_pin(UUID, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION verify_child_pin(UUID, TEXT) TO authenticated;

-- =====================================================
-- DONE! Child login should now work for unauthenticated users.
-- =====================================================
