-- =============================================
-- FIX TASK COMPLETION RLS
-- Run this in Supabase SQL Editor
-- =============================================

-- =============================================
-- STEP 1: DROP ALL EXISTING TASK POLICIES
-- =============================================
DROP POLICY IF EXISTS "Anyone can read tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Authenticated users can create tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Authenticated users can update tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Authenticated users can delete tasks" ON tidy_tasks;

-- =============================================
-- STEP 2: CREATE FULLY PERMISSIVE POLICIES
-- =============================================

-- Allow anyone to read tasks
CREATE POLICY "Anyone can read tasks" ON tidy_tasks
  FOR SELECT
  USING (true);

-- Allow anyone to insert tasks (authenticated or not for child login flow)
CREATE POLICY "Anyone can create tasks" ON tidy_tasks
  FOR INSERT
  WITH CHECK (true);

-- Allow anyone to update tasks (important for task completion by children)
CREATE POLICY "Anyone can update tasks" ON tidy_tasks
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Allow anyone to delete tasks
CREATE POLICY "Anyone can delete tasks" ON tidy_tasks
  FOR DELETE
  USING (true);

-- =============================================
-- STEP 3: ENSURE RLS IS ENABLED
-- =============================================
ALTER TABLE tidy_tasks ENABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 4: VERIFY POLICIES
-- =============================================
SELECT 
  policyname, 
  cmd,
  permissive,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'tidy_tasks';

-- =============================================
-- TEST: Try updating a task status manually
-- =============================================
-- Uncomment and run to test:
-- UPDATE tidy_tasks SET status = 'completed' WHERE id = 'YOUR_TASK_ID' RETURNING *;
