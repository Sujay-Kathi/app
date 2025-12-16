-- =====================================================
-- 🔧 FIX: RLS Policy and Auto-create Profile on Signup
-- =====================================================
-- Run this script in Supabase SQL Editor
-- This fixes the "new row violates row-level security policy" error
-- =====================================================

-- 1. Drop existing profile policies
DROP POLICY IF EXISTS "Users can insert own profile" ON public.tidy_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.tidy_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.tidy_profiles;

-- 2. Create new, more permissive policies for profiles
-- Allow authenticated users to insert their own profile
CREATE POLICY "Users can insert own profile" ON public.tidy_profiles 
    FOR INSERT 
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Allow users to view their own profile
CREATE POLICY "Users can view own profile" ON public.tidy_profiles 
    FOR SELECT 
    TO authenticated
    USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON public.tidy_profiles 
    FOR UPDATE 
    TO authenticated
    USING (auth.uid() = id);

-- 3. Create a trigger to auto-create profile when a user signs up
-- This is the BEST approach as it handles the timing issue

-- First, create the function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER  -- This is important! Runs with elevated privileges
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
    );
    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN
        -- Profile already exists, that's fine
        RETURN NEW;
    WHEN OTHERS THEN
        -- Log but don't fail
        RAISE WARNING 'Error creating profile: %', SQLERRM;
        RETURN NEW;
END;
$$;

-- Create the trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 4. Also fix the family policy to be more permissive for new users
DROP POLICY IF EXISTS "Authenticated users can create family" ON public.tidy_families;
CREATE POLICY "Authenticated users can create family" ON public.tidy_families 
    FOR INSERT 
    TO authenticated
    WITH CHECK (auth.uid() IS NOT NULL);

-- 5. Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.tidy_profiles TO authenticated;
GRANT ALL ON public.tidy_families TO authenticated;

-- =====================================================
-- DONE! 🎉
-- =====================================================
-- The trigger will now auto-create a profile when a user signs up.
-- You can also manually insert profiles - the RLS policy will allow it.
-- =====================================================
