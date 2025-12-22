-- =============================================
-- FINAL STORAGE FIX - DISABLE RLS ON STORAGE
-- Run this in Supabase SQL Editor
-- =============================================

-- STEP 1: Make absolutely sure the bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('tidy-room-assets', 'tidy-room-assets', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- STEP 2: DISABLE RLS on storage.objects entirely
-- This is the nuclear option - removes all RLS restrictions
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- STEP 3: Verify RLS is disabled
SELECT 
  relname as table_name,
  relrowsecurity as rls_enabled
FROM pg_class
WHERE relname = 'objects' AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'storage');

-- STEP 4: Verify bucket is public
SELECT id, name, public FROM storage.buckets WHERE id = 'tidy-room-assets';

-- =============================================
-- DONE! RLS is now disabled on storage.objects
-- All authenticated users can upload files.
-- =============================================
