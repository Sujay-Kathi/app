-- =============================================
-- FIX: ALLOW ANONYMOUS UPLOADS FOR CHILD PIN LOGIN
-- Run this in Supabase SQL Editor
-- =============================================

-- The issue: Children login with PIN (not Supabase Auth)
-- So they appear as 'anon' role, not 'authenticated'
-- This adds INSERT permission for anonymous users

-- STEP 1: Drop the existing authenticated-only insert policy
DROP POLICY IF EXISTS "tidy_room_assets_insert_policy" ON storage.objects;

-- STEP 2: Create a new INSERT policy that allows BOTH anon and authenticated
CREATE POLICY "tidy_room_assets_insert_policy"
ON storage.objects FOR INSERT
TO anon, authenticated
WITH CHECK (bucket_id = 'tidy-room-assets');

-- STEP 3: Verify all policies
SELECT 
  policyname,
  cmd,
  permissive,
  roles
FROM pg_policies 
WHERE tablename = 'objects' 
AND schemaname = 'storage'
ORDER BY policyname;

-- =============================================
-- DONE! Anonymous users (children with PIN login)
-- can now upload verification photos.
-- =============================================
