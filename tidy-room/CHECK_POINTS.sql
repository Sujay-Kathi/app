-- =============================================
-- CHECK POINTS AND TASK COMPLETION
-- Run this in Supabase SQL Editor
-- =============================================

-- =============================================
-- 1. CHECK CHILDREN'S POINTS
-- =============================================
SELECT 
  id,
  name,
  avatar_emoji,
  total_points,
  available_points,
  current_level,
  total_xp
FROM tidy_children
ORDER BY created_at DESC;

-- =============================================
-- 2. CHECK RECENT TASKS
-- =============================================
SELECT 
  t.id,
  t.title,
  t.points,
  t.status,
  t.completed_at,
  c.name as child_name
FROM tidy_tasks t
JOIN tidy_children c ON t.child_id = c.id
ORDER BY t.created_at DESC
LIMIT 20;

-- =============================================
-- 3. CHECK POINTS LOG TABLE STRUCTURE
-- =============================================
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tidy_points_log';

-- =============================================
-- 4. CHECK ALL POINTS LOG DATA
-- =============================================
SELECT * FROM tidy_points_log ORDER BY created_at DESC LIMIT 20;

-- =============================================
-- 5. CHECK STREAKS
-- =============================================
SELECT 
  s.*,
  c.name as child_name
FROM tidy_streaks s
JOIN tidy_children c ON s.child_id = c.id
ORDER BY s.current_streak DESC;

-- =============================================
-- 6. CHECK IF TRIGGERS EXIST FOR TASK COMPLETION
-- =============================================
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing
FROM information_schema.triggers
WHERE event_object_table = 'tidy_tasks';
