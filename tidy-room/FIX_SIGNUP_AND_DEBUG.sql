-- =====================================================
-- DIAGNOSTICS & FIX: Signup Flow
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Create the missing RPC function that AuthProvider tries to call
-- This ensures families are created securely on the server side
CREATE OR REPLACE FUNCTION public.create_family_for_user(p_family_name text, p_user_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with admin privileges to bypass RLS issues
SET search_path = public
AS $$
DECLARE
    v_family_record record;
BEGIN
    -- Insert family
    INSERT INTO public.tidy_families (name, created_by)
    VALUES (p_family_name, p_user_id)
    RETURNING * INTO v_family_record;

    -- Update profile with family_id
    UPDATE public.tidy_profiles
    SET family_id = v_family_record.id
    WHERE id = p_user_id;

    RETURN row_to_json(v_family_record);
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error creating family: %', SQLERRM;
    RETURN NULL;
END;
$$;

-- 2. Force-Recreate the Profile Trigger (just to be absolutely safe)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.tidy_profiles (id, email, display_name, role, is_primary_parent)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        'parent',
        true
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        display_name = EXCLUDED.display_name; -- Update if exists (e.g. if previous attempt failed partially)
    RETURN NEW;
END;
$$;

-- 3. DIAGNOSTICS: See what data currently exists (Top 5 most recent)
SELECT 'AUTH USERS' as table_name, id, email, created_at FROM auth.users ORDER BY created_at DESC LIMIT 5;
SELECT 'PROFILES' as table_name, id, email, family_id FROM public.tidy_profiles ORDER BY created_at DESC LIMIT 5;
SELECT 'FAMILIES' as table_name, id, name, created_by FROM public.tidy_families ORDER BY created_at DESC LIMIT 5;

-- 4. Grant permission to execute the new function
GRANT EXECUTE ON FUNCTION public.create_family_for_user(text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_family_for_user(text, uuid) TO anon; -- Allow anon for sign-up flow if needed

