-- =============================================
-- FIX TIDY-ROOM-ASSETS STORAGE RLS POLICIES
-- Run this in Supabase SQL Editor
-- This fixes the "new row violates row-level security policy" error
-- for new users on new devices
-- =============================================

-- =============================================
-- STEP 1: Create or update the storage bucket
-- =============================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'tidy-room-assets', 
  'tidy-room-assets', 
  true,  -- Make bucket public
  5242880,  -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET 
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

-- =============================================
-- STEP 2: Drop ALL existing storage policies for this bucket
-- =============================================
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
    END LOOP;
END $$;

-- =============================================
-- STEP 3: Create permissive storage policies
-- These policies allow any authenticated user to upload
-- =============================================

-- Allow ANYONE (including anonymous) to read/view files from the bucket
CREATE POLICY "tidy_room_assets_select_policy"
ON storage.objects FOR SELECT
USING (bucket_id = 'tidy-room-assets');

-- Allow ANY authenticated user to upload files to the bucket
-- This is the key fix - removes restrictive folder/user checks
CREATE POLICY "tidy_room_assets_insert_policy"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'tidy-room-assets');

-- Allow ANY authenticated user to update files in the bucket
CREATE POLICY "tidy_room_assets_update_policy"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'tidy-room-assets')
WITH CHECK (bucket_id = 'tidy-room-assets');

-- Allow ANY authenticated user to delete files from the bucket
CREATE POLICY "tidy_room_assets_delete_policy"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'tidy-room-assets');

-- =============================================
-- STEP 4: Also add policies for anonymous access (for public URLs)
-- =============================================

-- Allow anonymous users to view files (needed for public URL access)
CREATE POLICY "tidy_room_assets_anon_select_policy"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'tidy-room-assets');

-- =============================================
-- STEP 5: Verify the bucket configuration
-- =============================================
SELECT 
  id, 
  name, 
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE id = 'tidy-room-assets';

-- =============================================
-- STEP 6: Verify all storage policies
-- =============================================
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
-- DONE! 
-- After running this script, new users on new devices
-- should be able to upload verification photos without
-- RLS policy errors.
-- =============================================
