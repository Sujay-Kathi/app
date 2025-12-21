-- =====================================================
-- SETUP SUPABASE STORAGE FOR PHOTO VERIFICATION
-- Run this in Supabase SQL Editor
-- =====================================================

-- Create storage bucket for tidy room assets (verification photos)
-- Note: You may need to do this via Supabase Dashboard -> Storage -> New Bucket
-- Bucket name: tidy-room-assets
-- Public: Yes

-- If the bucket exists, create RLS policies for it:

-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload verification photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'tidy-room-assets' AND (storage.foldername(name))[1] = 'verification-photos');

-- Allow public read access
CREATE POLICY "Public can view verification photos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'tidy-room-assets');

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Users can delete their verification photos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'tidy-room-assets');

-- =====================================================
-- IMPORTANT: Also create the bucket manually in Supabase Dashboard
-- 1. Go to Supabase Dashboard -> Storage
-- 2. Click "New Bucket"
-- 3. Name: tidy-room-assets
-- 4. Check "Public bucket" 
-- 5. Click "Create bucket"
-- =====================================================
