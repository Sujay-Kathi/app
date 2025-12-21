-- =====================================================
-- FIX EXISTING USERS WITHOUT FAMILIES
-- Run this in Supabase SQL Editor
-- =====================================================
-- This script finds all profiles without a family_id and creates families for them

-- Step 1: View existing profiles without families (diagnostic)
SELECT 
    p.id as user_id,
    p.email,
    p.display_name,
    p.family_id,
    CASE WHEN p.family_id IS NULL THEN '❌ MISSING' ELSE '✅ OK' END as family_status
FROM public.tidy_profiles p
ORDER BY p.created_at DESC;

-- Step 2: Create families for all users who don't have one
DO $$
DECLARE
    profile_record RECORD;
    new_family_id UUID;
    fixed_count INTEGER := 0;
BEGIN
    -- Loop through all profiles that don't have a family_id
    FOR profile_record IN 
        SELECT id, display_name, email 
        FROM public.tidy_profiles 
        WHERE family_id IS NULL
    LOOP
        -- Create a new family for this user
        INSERT INTO public.tidy_families (name, created_by)
        VALUES (
            COALESCE(profile_record.display_name, split_part(profile_record.email, '@', 1)) || '''s Family',
            profile_record.id
        )
        RETURNING id INTO new_family_id;
        
        -- Update the profile with the new family_id
        UPDATE public.tidy_profiles
        SET family_id = new_family_id
        WHERE id = profile_record.id;
        
        fixed_count := fixed_count + 1;
        RAISE NOTICE 'Created family for user: % (email: %)', profile_record.display_name, profile_record.email;
    END LOOP;
    
    RAISE NOTICE '✅ Fixed % user(s) without families', fixed_count;
END $$;

-- Step 3: Verify the fix - all profiles should now have families
SELECT 
    p.id as user_id,
    p.email,
    p.display_name,
    p.family_id,
    f.name as family_name,
    CASE WHEN p.family_id IS NULL THEN '❌ STILL MISSING' ELSE '✅ FIXED' END as status
FROM public.tidy_profiles p
LEFT JOIN public.tidy_families f ON p.family_id = f.id
ORDER BY p.created_at DESC;

-- =====================================================
-- DONE! All existing users should now have families.
-- =====================================================
