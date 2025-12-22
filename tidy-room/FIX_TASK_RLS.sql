-- =============================================
-- FIX TASK RLS POLICIES (Updated)
-- Run this in Supabase SQL Editor
-- =============================================

-- =============================================
-- STEP 1: DROP ALL EXISTING TASK POLICIES
-- =============================================
DROP POLICY IF EXISTS "Anyone can read tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Authenticated users can create tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Authenticated users can update tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Authenticated users can delete tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Users can view own family tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Parents can create tasks for family children" ON tidy_tasks;
DROP POLICY IF EXISTS "Parents can update family tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "task_select_policy" ON tidy_tasks;
DROP POLICY IF EXISTS "task_insert_policy" ON tidy_tasks;
DROP POLICY IF EXISTS "task_update_policy" ON tidy_tasks;
DROP POLICY IF EXISTS "task_delete_policy" ON tidy_tasks;

-- =============================================
-- STEP 2: CREATE NEW PERMISSIVE POLICIES
-- =============================================

-- Allow anyone to read tasks (for children to see their tasks)
CREATE POLICY "Anyone can read tasks" ON tidy_tasks
  FOR SELECT
  USING (true);

-- Allow authenticated users to insert tasks
CREATE POLICY "Authenticated users can create tasks" ON tidy_tasks
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Allow authenticated users to update tasks
CREATE POLICY "Authenticated users can update tasks" ON tidy_tasks
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to delete tasks
CREATE POLICY "Authenticated users can delete tasks" ON tidy_tasks
  FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- =============================================
-- STEP 3: ENABLE RLS
-- =============================================
ALTER TABLE tidy_tasks ENABLE ROW LEVEL SECURITY;

-- =============================================
-- STEP 4: VERIFY POLICIES
-- =============================================
SELECT 
  policyname, 
  cmd,
  permissive
FROM pg_policies 
WHERE tablename = 'tidy_tasks';

-- =============================================
-- STEP 5: CHECK EXISTING TASKS
-- =============================================
SELECT 
  id, 
  child_id, 
  title, 
  status, 
  created_at 
FROM tidy_tasks 
ORDER BY created_at DESC 
LIMIT 10;

-- =============================================
-- STEP 6: CHECK CHILDREN
-- =============================================
SELECT id, name, family_id FROM tidy_children LIMIT 10;
