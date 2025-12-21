-- =====================================================
-- COMPLETE RLS FIX FOR ALL TABLES
-- Run this in Supabase SQL Editor
-- =====================================================

-- Step 1: Remove ALL existing policies on all tables
DO $$
DECLARE
    policy_record RECORD;
    tables_to_fix TEXT[] := ARRAY['tidy_families', 'tidy_profiles', 'tidy_children', 'tidy_rooms', 'tidy_tasks', 'tidy_streaks', 'tidy_achievements', 'tidy_points_log', 'tidy_levels', 'tidy_task_templates', 'tidy_decorations', 'tidy_inventory'];
    table_name TEXT;
BEGIN
    FOREACH table_name IN ARRAY tables_to_fix
    LOOP
        FOR policy_record IN 
            SELECT policyname FROM pg_policies WHERE tablename = table_name
        LOOP
            EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public.' || table_name;
        END LOOP;
    END LOOP;
END $$;

-- Step 2: Enable RLS on all tables (with permissive policies)
ALTER TABLE public.tidy_families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_points_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_task_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_decorations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_inventory ENABLE ROW LEVEL SECURITY;

-- Step 3: Create permissive policies for authenticated users

-- PROFILES
CREATE POLICY "profiles_all" ON public.tidy_profiles FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- FAMILIES
CREATE POLICY "families_all" ON public.tidy_families FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- CHILDREN
CREATE POLICY "children_all" ON public.tidy_children FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "children_anon_select" ON public.tidy_children FOR SELECT TO anon USING (true);

-- ROOMS
CREATE POLICY "rooms_all" ON public.tidy_rooms FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- TASKS
CREATE POLICY "tasks_all" ON public.tidy_tasks FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- STREAKS
CREATE POLICY "streaks_all" ON public.tidy_streaks FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ACHIEVEMENTS (unlocked by child)
CREATE POLICY "achievements_all" ON public.tidy_achievements FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- POINTS LOG
CREATE POLICY "points_log_all" ON public.tidy_points_log FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- LEVELS (read-only system data)
CREATE POLICY "levels_select" ON public.tidy_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY "levels_anon_select" ON public.tidy_levels FOR SELECT TO anon USING (true);

-- TASK TEMPLATES (read-only system data)
CREATE POLICY "templates_select" ON public.tidy_task_templates FOR SELECT TO authenticated USING (true);
CREATE POLICY "templates_anon_select" ON public.tidy_task_templates FOR SELECT TO anon USING (true);

-- DECORATIONS (read-only system data)
CREATE POLICY "decorations_select" ON public.tidy_decorations FOR SELECT TO authenticated USING (true);
CREATE POLICY "decorations_anon_select" ON public.tidy_decorations FOR SELECT TO anon USING (true);

-- INVENTORY
CREATE POLICY "inventory_all" ON public.tidy_inventory FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Step 4: Create the auto-profile trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.tidy_profiles (id, email, display_name, role, is_primary_parent)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        'parent',
        true
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_new_user();

-- Step 5: Grant all permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Step 6: Insert default levels if they don't exist
INSERT INTO public.tidy_levels (level, title, xp_required, icon) VALUES
(1, 'Newbie Cleaner', 0, '🌱'),
(2, 'Tidy Beginner', 100, '🌿'),
(3, 'Clean Rookie', 300, '🍀'),
(4, 'Neat Helper', 600, '🌻'),
(5, 'Junior Tidier', 1000, '🌺'),
(6, 'Room Ranger', 1500, '🌸'),
(7, 'Cleanliness Champ', 2100, '🌼'),
(8, 'Order Expert', 2800, '🌹'),
(9, 'Tidy Master', 3600, '🏵️'),
(10, 'Master Cleaner', 4500, '💐'),
(15, 'Pro Cleaner', 8000, '🏆'),
(20, 'Expert Cleaner', 13000, '👑'),
(30, 'Legendary Cleaner', 25000, '⭐'),
(50, 'Cleaning God', 50000, '💎')
ON CONFLICT (level) DO NOTHING;

-- Step 7: Insert default task templates if they don't exist
INSERT INTO public.tidy_task_templates (title, description, zone, difficulty, points, icon, estimated_minutes) VALUES
('Make the Bed', 'Straighten sheets and arrange pillows neatly', 'bed', 'easy', 15, '🛏️', 5),
('Pick Up Toys', 'Put all toys back in their proper places', 'floor', 'easy', 20, '🧸', 10),
('Clear Desk Clutter', 'Organize papers and supplies on desk', 'desk', 'medium', 25, '📚', 10),
('Empty Trash Bin', 'Take out the trash and replace bag', 'general', 'easy', 10, '🗑️', 5),
('Organize Bookshelf', 'Arrange books neatly on shelves', 'desk', 'medium', 35, '📖', 15),
('Fold Clothes', 'Fold clean laundry neatly', 'closet', 'medium', 30, '👕', 15),
('Vacuum Floor', 'Vacuum the entire room floor', 'floor', 'hard', 50, '🧹', 20),
('Dust Surfaces', 'Wipe down all dusty surfaces', 'general', 'medium', 35, '✨', 15),
('Organize Closet', 'Sort and arrange items in closet', 'closet', 'hard', 45, '🚪', 20),
('Clean Windows', 'Wipe windows and glass surfaces', 'general', 'medium', 30, '🪟', 15)
ON CONFLICT DO NOTHING;

-- =====================================================
-- DONE! All tables now have permissive RLS policies.
-- =====================================================
