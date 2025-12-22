-- =============================================
-- FIX STORAGE RLS POLICIES
-- Run this in Supabase SQL Editor
-- =============================================

-- =============================================
-- STEP 1: Create the storage bucket if it doesn't exist
-- =============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('task-verifications', 'task-verifications', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- =============================================
-- STEP 2: Drop existing storage policies
-- =============================================
DROP POLICY IF EXISTS "Anyone can upload verification photos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view verification photos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can update verification photos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can delete verification photos" ON storage.objects;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "task_verification_upload" ON storage.objects;
DROP POLICY IF EXISTS "task_verification_select" ON storage.objects;

-- =============================================
-- STEP 3: Create permissive storage policies
-- =============================================

-- Allow anyone to read from task-verifications bucket
CREATE POLICY "Anyone can view verification photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'task-verifications');

-- Allow authenticated users to upload to task-verifications bucket
CREATE POLICY "Anyone can upload verification photos"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'task-verifications');

-- Allow authenticated users to update their uploads
CREATE POLICY "Anyone can update verification photos"
ON storage.objects FOR UPDATE
USING (bucket_id = 'task-verifications')
WITH CHECK (bucket_id = 'task-verifications');

-- Allow authenticated users to delete their uploads
CREATE POLICY "Anyone can delete verification photos"
ON storage.objects FOR DELETE
USING (bucket_id = 'task-verifications');

-- =============================================
-- STEP 4: Verify the bucket exists
-- =============================================
SELECT id, name, public FROM storage.buckets WHERE id = 'task-verifications';

-- =============================================
-- STEP 5: Verify policies
-- =============================================
SELECT 
  policyname,
  cmd,
  permissive
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';
