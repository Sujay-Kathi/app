-- =============================================
-- FIX: ALLOW ANONYMOUS ACCESS FOR CHILD PIN LOGIN
-- Run this in Supabase SQL Editor
-- =============================================
-- The issue: Children login with PIN (not Supabase Auth)
-- So they appear as 'anon' role, not 'authenticated'
-- This adds read/write permissions for anonymous users on child-related tables

-- =============================================
-- STEP 1: Fix tidy_children table (child data access)
-- =============================================
DROP POLICY IF EXISTS "children_all" ON public.tidy_children;
DROP POLICY IF EXISTS "children_anon_select" ON public.tidy_children;
DROP POLICY IF EXISTS "children_anon_all" ON public.tidy_children;

-- Allow authenticated users full access
CREATE POLICY "children_all" ON public.tidy_children 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users (children with PIN) full access
CREATE POLICY "children_anon_all" ON public.tidy_children 
FOR ALL TO anon 
USING (true) WITH CHECK (true);

-- =============================================
-- STEP 2: Fix tidy_tasks table (task data access)
-- =============================================
DROP POLICY IF EXISTS "tasks_all" ON public.tidy_tasks;
DROP POLICY IF EXISTS "tasks_anon_all" ON public.tidy_tasks;

-- Allow authenticated users full access
CREATE POLICY "tasks_all" ON public.tidy_tasks 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users (children with PIN) full access
CREATE POLICY "tasks_anon_all" ON public.tidy_tasks 
FOR ALL TO anon 
USING (true) WITH CHECK (true);

-- =============================================
-- STEP 3: Fix tidy_streaks table (streak data access)
-- =============================================
DROP POLICY IF EXISTS "streaks_all" ON public.tidy_streaks;
DROP POLICY IF EXISTS "streaks_anon_all" ON public.tidy_streaks;

-- Allow authenticated users full access
CREATE POLICY "streaks_all" ON public.tidy_streaks 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users (children with PIN) full access
CREATE POLICY "streaks_anon_all" ON public.tidy_streaks 
FOR ALL TO anon 
USING (true) WITH CHECK (true);

-- =============================================
-- STEP 4: Fix tidy_child_achievements table
-- =============================================
DROP POLICY IF EXISTS "achievements_all" ON public.tidy_achievements;
DROP POLICY IF EXISTS "achievements_anon_all" ON public.tidy_achievements;

-- Allow authenticated users full access
CREATE POLICY "achievements_all" ON public.tidy_achievements 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users read access
CREATE POLICY "achievements_anon_all" ON public.tidy_achievements 
FOR SELECT TO anon 
USING (true);

-- =============================================
-- STEP 5: Fix tidy_child_achievements table (junction table)
-- =============================================
-- Check if this table exists first
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tidy_child_achievements') THEN
        EXECUTE 'DROP POLICY IF EXISTS "child_achievements_all" ON public.tidy_child_achievements';
        EXECUTE 'DROP POLICY IF EXISTS "child_achievements_anon_all" ON public.tidy_child_achievements';
        
        EXECUTE 'CREATE POLICY "child_achievements_all" ON public.tidy_child_achievements 
                 FOR ALL TO authenticated 
                 USING (true) WITH CHECK (true)';
        
        EXECUTE 'CREATE POLICY "child_achievements_anon_all" ON public.tidy_child_achievements 
                 FOR ALL TO anon 
                 USING (true) WITH CHECK (true)';
    END IF;
END $$;

-- =============================================
-- STEP 6: Fix tidy_points_log table (points history)
-- =============================================
DROP POLICY IF EXISTS "points_log_all" ON public.tidy_points_log;
DROP POLICY IF EXISTS "points_log_anon_all" ON public.tidy_points_log;

-- Allow authenticated users full access
CREATE POLICY "points_log_all" ON public.tidy_points_log 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users full access
CREATE POLICY "points_log_anon_all" ON public.tidy_points_log 
FOR ALL TO anon 
USING (true) WITH CHECK (true);

-- =============================================
-- STEP 7: Fix tidy_levels table (level info - read only)
-- =============================================
DROP POLICY IF EXISTS "levels_select" ON public.tidy_levels;
DROP POLICY IF EXISTS "levels_anon_select" ON public.tidy_levels;

-- Allow everyone to read levels
CREATE POLICY "levels_select" ON public.tidy_levels 
FOR SELECT TO authenticated 
USING (true);

CREATE POLICY "levels_anon_select" ON public.tidy_levels 
FOR SELECT TO anon 
USING (true);

-- =============================================
-- STEP 8: Fix tidy_rooms table (room data access)
-- =============================================
DROP POLICY IF EXISTS "rooms_all" ON public.tidy_rooms;
DROP POLICY IF EXISTS "rooms_anon_all" ON public.tidy_rooms;

-- Allow authenticated users full access
CREATE POLICY "rooms_all" ON public.tidy_rooms 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users full access
CREATE POLICY "rooms_anon_all" ON public.tidy_rooms 
FOR ALL TO anon 
USING (true) WITH CHECK (true);

-- =============================================
-- STEP 9: Fix tidy_inventory table (store/inventory access)
-- =============================================
DROP POLICY IF EXISTS "inventory_all" ON public.tidy_inventory;
DROP POLICY IF EXISTS "inventory_anon_all" ON public.tidy_inventory;

-- Allow authenticated users full access
CREATE POLICY "inventory_all" ON public.tidy_inventory 
FOR ALL TO authenticated 
USING (true) WITH CHECK (true);

-- Allow anonymous users full access
CREATE POLICY "inventory_anon_all" ON public.tidy_inventory 
FOR ALL TO anon 
USING (true) WITH CHECK (true);

-- =============================================
-- STEP 10: Fix tidy_decorations table (store items - read only)
-- =============================================
DROP POLICY IF EXISTS "decorations_select" ON public.tidy_decorations;
DROP POLICY IF EXISTS "decorations_anon_select" ON public.tidy_decorations;

-- Allow everyone to read decorations
CREATE POLICY "decorations_select" ON public.tidy_decorations 
FOR SELECT TO authenticated 
USING (true);

CREATE POLICY "decorations_anon_select" ON public.tidy_decorations 
FOR SELECT TO anon 
USING (true);

-- =============================================
-- STEP 11: Grant permissions
-- =============================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;

-- =============================================
-- STEP 12: Verify policies
-- =============================================
SELECT 
  tablename,
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename LIKE 'tidy_%'
ORDER BY tablename, policyname;

-- =============================================
-- DONE! Anonymous users (children with PIN login)
-- can now access all necessary tables.
-- =============================================
