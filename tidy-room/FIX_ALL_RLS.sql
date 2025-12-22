-- =============================================
-- FIX ALL RLS POLICIES (COMPREHENSIVE)
-- Run this in Supabase SQL Editor
-- =============================================

-- =============================================
-- FIX tidy_points_log TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read points log" ON tidy_points_log;
DROP POLICY IF EXISTS "Anyone can create points log" ON tidy_points_log;
DROP POLICY IF EXISTS "Anyone can update points log" ON tidy_points_log;
DROP POLICY IF EXISTS "Anyone can delete points log" ON tidy_points_log;

CREATE POLICY "Anyone can read points log" ON tidy_points_log
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create points log" ON tidy_points_log
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update points log" ON tidy_points_log
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete points log" ON tidy_points_log
  FOR DELETE USING (true);

ALTER TABLE tidy_points_log ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FIX tidy_streaks TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read streaks" ON tidy_streaks;
DROP POLICY IF EXISTS "Anyone can create streaks" ON tidy_streaks;
DROP POLICY IF EXISTS "Anyone can update streaks" ON tidy_streaks;
DROP POLICY IF EXISTS "Anyone can delete streaks" ON tidy_streaks;

CREATE POLICY "Anyone can read streaks" ON tidy_streaks
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create streaks" ON tidy_streaks
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update streaks" ON tidy_streaks
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete streaks" ON tidy_streaks
  FOR DELETE USING (true);

ALTER TABLE tidy_streaks ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FIX tidy_child_achievements TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read child achievements" ON tidy_child_achievements;
DROP POLICY IF EXISTS "Anyone can create child achievements" ON tidy_child_achievements;
DROP POLICY IF EXISTS "Anyone can update child achievements" ON tidy_child_achievements;
DROP POLICY IF EXISTS "Anyone can delete child achievements" ON tidy_child_achievements;

CREATE POLICY "Anyone can read child achievements" ON tidy_child_achievements
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create child achievements" ON tidy_child_achievements
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update child achievements" ON tidy_child_achievements
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete child achievements" ON tidy_child_achievements
  FOR DELETE USING (true);

ALTER TABLE tidy_child_achievements ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FIX tidy_children TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read children" ON tidy_children;
DROP POLICY IF EXISTS "Anyone can create children" ON tidy_children;
DROP POLICY IF EXISTS "Anyone can update children" ON tidy_children;
DROP POLICY IF EXISTS "Anyone can delete children" ON tidy_children;

CREATE POLICY "Anyone can read children" ON tidy_children
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create children" ON tidy_children
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update children" ON tidy_children
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete children" ON tidy_children
  FOR DELETE USING (true);

ALTER TABLE tidy_children ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FIX tidy_rooms TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read rooms" ON tidy_rooms;
DROP POLICY IF EXISTS "Anyone can create rooms" ON tidy_rooms;
DROP POLICY IF EXISTS "Anyone can update rooms" ON tidy_rooms;
DROP POLICY IF EXISTS "Anyone can delete rooms" ON tidy_rooms;

CREATE POLICY "Anyone can read rooms" ON tidy_rooms
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create rooms" ON tidy_rooms
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update rooms" ON tidy_rooms
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete rooms" ON tidy_rooms
  FOR DELETE USING (true);

ALTER TABLE tidy_rooms ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FIX tidy_tasks TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Anyone can create tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Anyone can update tasks" ON tidy_tasks;
DROP POLICY IF EXISTS "Anyone can delete tasks" ON tidy_tasks;

CREATE POLICY "Anyone can read tasks" ON tidy_tasks
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create tasks" ON tidy_tasks
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update tasks" ON tidy_tasks
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete tasks" ON tidy_tasks
  FOR DELETE USING (true);

ALTER TABLE tidy_tasks ENABLE ROW LEVEL SECURITY;

-- =============================================
-- FIX tidy_families TABLE
-- =============================================
DROP POLICY IF EXISTS "Anyone can read families" ON tidy_families;
DROP POLICY IF EXISTS "Anyone can create families" ON tidy_families;
DROP POLICY IF EXISTS "Anyone can update families" ON tidy_families;
DROP POLICY IF EXISTS "Anyone can delete families" ON tidy_families;

CREATE POLICY "Anyone can read families" ON tidy_families
  FOR SELECT USING (true);

CREATE POLICY "Anyone can create families" ON tidy_families
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update families" ON tidy_families
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can delete families" ON tidy_families
  FOR DELETE USING (true);

ALTER TABLE tidy_families ENABLE ROW LEVEL SECURITY;

-- =============================================
-- VERIFY ALL POLICIES
-- =============================================
SELECT 
  tablename,
  policyname, 
  cmd
FROM pg_policies 
WHERE schemaname = 'public' AND tablename LIKE 'tidy_%'
ORDER BY tablename, cmd;
