-- =====================================================
-- 🏠 TIDY ROOM SIMULATOR - SUPABASE DATABASE SETUP
-- =====================================================
-- Run this script in Supabase SQL Editor
-- This creates all tables for the Tidy Room Simulator app
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. FAMILIES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_families (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    invite_code TEXT UNIQUE DEFAULT SUBSTRING(MD5(RANDOM()::TEXT), 1, 8),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 2. PROFILES TABLE (extends auth.users)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    family_id UUID REFERENCES public.tidy_families(id) ON DELETE SET NULL,
    email TEXT,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'parent' CHECK (role IN ('parent', 'child')),
    is_primary_parent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. CHILDREN TABLE (child-specific data)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_children (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES public.tidy_profiles(id) ON DELETE CASCADE UNIQUE,
    family_id UUID REFERENCES public.tidy_families(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    age INTEGER CHECK (age >= 1 AND age <= 18),
    avatar_emoji TEXT DEFAULT '👦',
    pin_code TEXT, -- 4-digit PIN for child login
    total_points INTEGER DEFAULT 0,
    available_points INTEGER DEFAULT 0, -- Points that can be spent
    current_level INTEGER DEFAULT 1,
    total_xp INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 4. THEMES TABLE (room themes)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_themes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    preview_url TEXT,
    price INTEGER NOT NULL DEFAULT 0,
    is_default BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    colors JSONB DEFAULT '{}', -- Theme color palette
    assets JSONB DEFAULT '{}', -- URLs or paths to theme assets
    unlock_level INTEGER DEFAULT 1, -- Minimum level to purchase
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 5. ROOMS TABLE (virtual room for each child)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_rooms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE UNIQUE,
    theme_id UUID REFERENCES public.tidy_themes(id) DEFAULT NULL,
    cleanliness_score INTEGER DEFAULT 0 CHECK (cleanliness_score >= 0 AND cleanliness_score <= 100),
    zone_bed INTEGER DEFAULT 0 CHECK (zone_bed >= 0 AND zone_bed <= 100),
    zone_floor INTEGER DEFAULT 0 CHECK (zone_floor >= 0 AND zone_floor <= 100),
    zone_desk INTEGER DEFAULT 0 CHECK (zone_desk >= 0 AND zone_desk <= 100),
    zone_closet INTEGER DEFAULT 0 CHECK (zone_closet >= 0 AND zone_closet <= 100),
    zone_general INTEGER DEFAULT 0 CHECK (zone_general >= 0 AND zone_general <= 100),
    last_cleaned_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 6. TASK TEMPLATES TABLE (pre-defined tasks)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_task_templates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    zone TEXT NOT NULL CHECK (zone IN ('bed', 'floor', 'desk', 'closet', 'general')),
    default_points INTEGER NOT NULL DEFAULT 10,
    difficulty TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    icon TEXT DEFAULT '✨',
    estimated_minutes INTEGER DEFAULT 5,
    is_system BOOLEAN DEFAULT TRUE, -- System templates vs custom
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 7. TASKS TABLE (assigned tasks)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    template_id UUID REFERENCES public.tidy_task_templates(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    zone TEXT NOT NULL CHECK (zone IN ('bed', 'floor', 'desk', 'closet', 'general')),
    points INTEGER NOT NULL CHECK (points > 0),
    difficulty TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    icon TEXT DEFAULT '✨',
    frequency TEXT DEFAULT 'one_time' CHECK (frequency IN ('daily', 'weekly', 'one_time')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'verified', 'rejected', 'expired')),
    due_date TIMESTAMPTZ,
    requires_verification BOOLEAN DEFAULT FALSE,
    verification_photo_url TEXT,
    completed_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 8. RECURRING TASKS TABLE (for scheduling)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_recurring_tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    template_id UUID REFERENCES public.tidy_task_templates(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    zone TEXT NOT NULL CHECK (zone IN ('bed', 'floor', 'desk', 'closet', 'general')),
    points INTEGER NOT NULL,
    difficulty TEXT DEFAULT 'medium',
    icon TEXT DEFAULT '✨',
    frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly')),
    days_of_week INTEGER[] DEFAULT '{1,2,3,4,5,6,0}', -- 0=Sun, 1=Mon, etc.
    scheduled_time TIME DEFAULT '09:00:00',
    is_active BOOLEAN DEFAULT TRUE,
    last_generated_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 9. POINTS LOG TABLE (transaction history)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_points_log (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE NOT NULL,
    points INTEGER NOT NULL, -- Positive = earned, Negative = spent
    balance_after INTEGER NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('task_complete', 'streak_bonus', 'level_up', 'purchase', 'adjustment', 'bonus')),
    description TEXT NOT NULL,
    task_id UUID REFERENCES public.tidy_tasks(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 10. STREAKS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_streaks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE UNIQUE NOT NULL,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    streak_multiplier DECIMAL(3,2) DEFAULT 1.00, -- 1.00 = 100%, 1.25 = 125%
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 11. DECORATIONS TABLE (store items)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_decorations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('wall', 'furniture', 'accessory', 'effect', 'pet')),
    zone TEXT CHECK (zone IN ('bed', 'floor', 'desk', 'closet', 'general', 'any')),
    icon TEXT DEFAULT '🎨', -- Emoji icon for the decoration
    preview_url TEXT,
    asset_url TEXT,
    price INTEGER NOT NULL DEFAULT 100,
    is_premium BOOLEAN DEFAULT FALSE,
    unlock_level INTEGER DEFAULT 1,
    position_data JSONB DEFAULT '{}', -- Default position in room
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 12. INVENTORY TABLE (child's purchased items)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_inventory (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE NOT NULL,
    item_id UUID NOT NULL,
    item_type TEXT NOT NULL CHECK (item_type IN ('theme', 'decoration')),
    is_equipped BOOLEAN DEFAULT FALSE,
    position JSONB DEFAULT '{}', -- Position in room if equipped
    purchased_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, item_id, item_type)
);

-- =====================================================
-- 13. ACHIEVEMENTS TABLE (badges/achievements)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT DEFAULT '🏆',
    category TEXT CHECK (category IN ('streak', 'tasks', 'points', 'level', 'special')),
    requirement_type TEXT NOT NULL, -- e.g., 'streak_days', 'tasks_completed', etc.
    requirement_value INTEGER NOT NULL,
    xp_reward INTEGER DEFAULT 0,
    points_reward INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 14. CHILD ACHIEVEMENTS TABLE (unlocked achievements)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_child_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES public.tidy_achievements(id) ON DELETE CASCADE NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, achievement_id)
);

-- =====================================================
-- 15. LEVELS TABLE (level progression)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_levels (
    level INTEGER PRIMARY KEY,
    title TEXT NOT NULL, -- e.g., "Beginner Cleaner", "Tidy Master"
    xp_required INTEGER NOT NULL,
    icon TEXT DEFAULT '⭐',
    rewards JSONB DEFAULT '{}', -- Unlocks at this level
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 16. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT CHECK (type IN ('task_assigned', 'task_completed', 'streak_warning', 'achievement', 'reward', 'system')),
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 17. ACTIVITY LOG TABLE (for parent dashboard)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tidy_activity_log (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    family_id UUID REFERENCES public.tidy_families(id) ON DELETE CASCADE NOT NULL,
    child_id UUID REFERENCES public.tidy_children(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INSERT DEFAULT DATA
-- =====================================================

-- Default Themes
INSERT INTO public.tidy_themes (name, description, price, is_default, colors) VALUES
    ('Default', 'A cozy, classic bedroom', 0, TRUE, '{"primary": "#8B5CF6", "secondary": "#F1F5F9", "accent": "#FBBF24"}'),
    ('Space Adventure', 'Explore the cosmos from your room!', 500, FALSE, '{"primary": "#1E3A8A", "secondary": "#0F172A", "accent": "#60A5FA"}'),
    ('Ocean Paradise', 'Dive into an underwater world', 500, FALSE, '{"primary": "#0891B2", "secondary": "#083344", "accent": "#22D3EE"}'),
    ('Jungle Safari', 'A wild adventure awaits!', 500, FALSE, '{"primary": "#15803D", "secondary": "#14532D", "accent": "#4ADE80"}'),
    ('Gaming Zone', 'Level up your room!', 750, FALSE, '{"primary": "#7C3AED", "secondary": "#1E1B4B", "accent": "#E879F9"}'),
    ('Candy Land', 'Sweet dreams in a colorful world', 600, FALSE, '{"primary": "#EC4899", "secondary": "#FDF2F8", "accent": "#F472B6"}'),
    ('Arctic Ice', 'Cool vibes in a winter wonderland', 500, FALSE, '{"primary": "#0EA5E9", "secondary": "#E0F2FE", "accent": "#38BDF8"}')
ON CONFLICT DO NOTHING;

-- Default Task Templates
INSERT INTO public.tidy_task_templates (title, description, zone, default_points, difficulty, icon, estimated_minutes) VALUES
    -- Bed Zone
    ('Make the Bed', 'Straighten sheets and arrange pillows neatly', 'bed', 15, 'easy', '🛏️', 3),
    ('Change Bed Sheets', 'Put on fresh, clean sheets', 'bed', 40, 'medium', '🛏️', 10),
    ('Fluff the Pillows', 'Make pillows nice and fluffy', 'bed', 10, 'easy', '🛌', 2),
    ('Organize Bedside Table', 'Tidy up items on bedside table', 'bed', 20, 'easy', '🪔', 5),
    
    -- Floor Zone
    ('Pick Up Toys', 'Collect toys from the floor', 'floor', 20, 'easy', '🧸', 5),
    ('Vacuum the Floor', 'Vacuum or sweep the entire floor', 'floor', 50, 'hard', '🧹', 15),
    ('Pick Up Clothes', 'Collect clothes from the floor', 'floor', 15, 'easy', '👕', 5),
    ('Mop the Floor', 'Mop hard floors clean', 'floor', 60, 'hard', '🧽', 20),
    
    -- Desk Zone
    ('Clear Desk Clutter', 'Remove unnecessary items from desk', 'desk', 25, 'medium', '📚', 10),
    ('Organize School Supplies', 'Arrange pens, pencils, and supplies', 'desk', 20, 'easy', '✏️', 8),
    ('Sort Papers', 'Organize homework and drawings', 'desk', 30, 'medium', '📄', 10),
    ('Clean Computer/Tablet', 'Wipe down screens and devices', 'desk', 25, 'medium', '💻', 5),
    ('Organize Bookshelf', 'Arrange books neatly on shelves', 'desk', 35, 'medium', '📖', 12),
    
    -- Closet Zone
    ('Hang Up Clothes', 'Hang clothes in the closet', 'closet', 30, 'medium', '👔', 10),
    ('Fold Clothes', 'Neatly fold and put away clothes', 'closet', 35, 'medium', '👕', 12),
    ('Organize Shoes', 'Line up shoes neatly', 'closet', 20, 'easy', '👟', 5),
    ('Sort Laundry', 'Separate dirty clothes by color', 'closet', 25, 'medium', '🧺', 8),
    ('Organize Closet', 'Deep clean and organize entire closet', 'closet', 60, 'hard', '🗄️', 25),
    
    -- General Zone
    ('Dust Surfaces', 'Dust furniture and surfaces', 'general', 30, 'medium', '🪥', 10),
    ('Empty Trash Bin', 'Take out trash and replace bag', 'general', 10, 'easy', '🗑️', 3),
    ('Clean Windows', 'Wipe window glass clean', 'general', 40, 'medium', '🪟', 12),
    ('Water Plants', 'Give plants a drink', 'general', 15, 'easy', '🌱', 5),
    ('General Tidying', 'Quick tidy of the room', 'general', 20, 'easy', '✨', 8)
ON CONFLICT DO NOTHING;

-- Default Decorations
INSERT INTO public.tidy_decorations (name, description, category, zone, price, icon) VALUES
    -- Wall Decorations
    ('Star Poster', 'A glowing star poster for your wall', 'wall', 'any', 50, '⭐'),
    ('Rainbow Sticker', 'Colorful rainbow wall sticker', 'wall', 'any', 75, '🌈'),
    ('Space Poster', 'Explore the galaxy!', 'wall', 'any', 100, '🚀'),
    ('Sports Poster', 'For the sports fan', 'wall', 'any', 80, '⚽'),
    ('Music Poster', 'Rock on!', 'wall', 'any', 80, '🎸'),
    ('World Map', 'Explore the world', 'wall', 'any', 120, '🗺️'),
    
    -- Furniture/Accessories
    ('Cozy Rug', 'A soft, colorful rug', 'furniture', 'floor', 150, '🟫'),
    ('Bean Bag', 'Comfy bean bag chair', 'furniture', 'floor', 200, '🛋️'),
    ('Desk Lamp', 'Bright LED desk lamp', 'furniture', 'desk', 100, '💡'),
    ('Bookends', 'Keep books organized', 'furniture', 'desk', 60, '📚'),
    ('Toy Box', 'Store your toys', 'furniture', 'floor', 180, '📦'),
    ('Night Light', 'Soft glow for nighttime', 'furniture', 'bed', 80, '🌙'),
    
    -- Effects
    ('Sparkle Effect', 'Add sparkles to your room', 'effect', 'any', 200, '✨'),
    ('Rainbow Glow', 'Colorful lighting effect', 'effect', 'any', 250, '🌈'),
    ('Stars Effect', 'Twinkling ceiling stars', 'effect', 'any', 300, '🌟'),
    
    -- Pets
    ('Lazy Cat', 'A cute sleeping cat', 'pet', 'any', 300, '😺'),
    ('Happy Dog', 'A playful puppy', 'pet', 'any', 300, '🐕'),
    ('Tiny Hamster', 'A little furry friend', 'pet', 'any', 250, '🐹'),
    ('Goldfish', 'Swimming in a bowl', 'pet', 'any', 150, '🐠'),
    ('Bunny', 'A fluffy bunny', 'pet', 'any', 350, '🐰')
ON CONFLICT DO NOTHING;

-- Default Achievements
INSERT INTO public.tidy_achievements (name, description, icon, category, requirement_type, requirement_value, xp_reward, points_reward) VALUES
    -- Streak Achievements
    ('First Steps', 'Complete tasks for 3 days in a row', '🎯', 'streak', 'streak_days', 3, 50, 25),
    ('Week Warrior', 'Maintain a 7-day streak', '🔥', 'streak', 'streak_days', 7, 100, 50),
    ('Two Week Champion', 'Keep a 14-day streak going', '💪', 'streak', 'streak_days', 14, 200, 100),
    ('Monthly Master', 'Incredible 30-day streak!', '🏆', 'streak', 'streak_days', 30, 500, 300),
    
    -- Task Achievements
    ('Getting Started', 'Complete your first task', '⭐', 'tasks', 'tasks_completed', 1, 25, 10),
    ('Task Tackler', 'Complete 10 tasks', '✅', 'tasks', 'tasks_completed', 10, 75, 30),
    ('Cleaning Machine', 'Complete 50 tasks', '🤖', 'tasks', 'tasks_completed', 50, 200, 100),
    ('Super Cleaner', 'Complete 100 tasks', '🦸', 'tasks', 'tasks_completed', 100, 400, 200),
    ('Legendary Cleaner', 'Complete 500 tasks', '👑', 'tasks', 'tasks_completed', 500, 1000, 500),
    
    -- Points Achievements
    ('Piggy Bank', 'Earn 100 total points', '🐷', 'points', 'total_points', 100, 25, 0),
    ('Coin Collector', 'Earn 500 total points', '💰', 'points', 'total_points', 500, 75, 0),
    ('Rich Kid', 'Earn 2000 total points', '💎', 'points', 'total_points', 2000, 200, 0),
    
    -- Level Achievements
    ('Level 5', 'Reach level 5', '🌟', 'level', 'level_reached', 5, 100, 50),
    ('Level 10', 'Reach level 10', '🎖️', 'level', 'level_reached', 10, 250, 100),
    ('Level 20', 'Reach level 20', '🏅', 'level', 'level_reached', 20, 500, 200),
    
    -- Special Achievements
    ('Early Bird', 'Complete a task before 8 AM', '🐦', 'special', 'early_task', 1, 50, 25),
    ('Night Owl', 'Complete a task after 8 PM', '🦉', 'special', 'night_task', 1, 50, 25),
    ('Speed Demon', 'Complete 5 tasks in one day', '⚡', 'special', 'tasks_one_day', 5, 100, 50),
    ('Perfect Week', 'Complete all assigned tasks in a week', '💯', 'special', 'perfect_week', 1, 200, 100)
ON CONFLICT DO NOTHING;

-- Default Levels
INSERT INTO public.tidy_levels (level, title, xp_required, icon, rewards) VALUES
    (1, 'Newbie Cleaner', 0, '🌱', '{}'),
    (2, 'Tidy Trainee', 100, '🌿', '{}'),
    (3, 'Neat Novice', 250, '🍀', '{}'),
    (4, 'Clean Cadet', 450, '⭐', '{}'),
    (5, 'Spotless Scout', 700, '🌟', '{"unlock_decoration": true}'),
    (6, 'Dust Buster', 1000, '💫', '{}'),
    (7, 'Tidy Titan', 1400, '🔥', '{}'),
    (8, 'Clean Captain', 1900, '🚀', '{}'),
    (9, 'Sparkle Star', 2500, '✨', '{}'),
    (10, 'Master Cleaner', 3200, '👑', '{"unlock_theme": true}'),
    (11, 'Hygiene Hero', 4000, '🦸', '{}'),
    (12, 'Pristine Pro', 5000, '💎', '{}'),
    (13, 'Orderly Oracle', 6200, '🔮', '{}'),
    (14, 'Gleaming Guardian', 7600, '🛡️', '{}'),
    (15, 'Legendary Cleaner', 9200, '🏆', '{"unlock_theme": true, "unlock_decoration": true}'),
    (16, 'Tidy Legend', 11000, '🌈', '{}'),
    (17, 'Clean Champion', 13000, '🎖️', '{}'),
    (18, 'Spotless Sage', 15500, '🧙', '{}'),
    (19, 'Immaculate Icon', 18500, '👼', '{}'),
    (20, 'Ultimate Cleaner', 22000, '🌟', '{"special_reward": true}')
ON CONFLICT DO NOTHING;

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update room cleanliness score
CREATE OR REPLACE FUNCTION calculate_room_cleanliness()
RETURNS TRIGGER AS $$
BEGIN
    NEW.cleanliness_score := (
        (NEW.zone_bed * 0.25) +
        (NEW.zone_floor * 0.25) +
        (NEW.zone_desk * 0.20) +
        (NEW.zone_closet * 0.20) +
        (NEW.zone_general * 0.10)
    )::INTEGER;
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for room cleanliness calculation
DROP TRIGGER IF EXISTS trigger_calculate_cleanliness ON public.tidy_rooms;
CREATE TRIGGER trigger_calculate_cleanliness
    BEFORE INSERT OR UPDATE OF zone_bed, zone_floor, zone_desk, zone_closet, zone_general
    ON public.tidy_rooms
    FOR EACH ROW
    EXECUTE FUNCTION calculate_room_cleanliness();

-- Function to handle task completion
CREATE OR REPLACE FUNCTION handle_task_completion()
RETURNS TRIGGER AS $$
DECLARE
    child RECORD;
    streak RECORD;
    bonus_multiplier DECIMAL;
    final_points INTEGER;
BEGIN
    IF NEW.status = 'completed' AND OLD.status = 'pending' THEN
        -- Get child info
        SELECT * INTO child FROM public.tidy_children WHERE id = NEW.child_id;
        
        -- Get or create streak
        SELECT * INTO streak FROM public.tidy_streaks WHERE child_id = NEW.child_id;
        
        IF streak IS NULL THEN
            INSERT INTO public.tidy_streaks (child_id, current_streak, last_activity_date)
            VALUES (NEW.child_id, 1, CURRENT_DATE)
            RETURNING * INTO streak;
            bonus_multiplier := 1.00;
        ELSE
            -- Update streak
            IF streak.last_activity_date = CURRENT_DATE THEN
                bonus_multiplier := streak.streak_multiplier;
            ELSIF streak.last_activity_date = CURRENT_DATE - INTERVAL '1 day' THEN
                -- Continue streak
                UPDATE public.tidy_streaks 
                SET current_streak = current_streak + 1,
                    last_activity_date = CURRENT_DATE,
                    streak_multiplier = CASE 
                        WHEN current_streak + 1 >= 30 THEN 2.00
                        WHEN current_streak + 1 >= 14 THEN 1.50
                        WHEN current_streak + 1 >= 7 THEN 1.25
                        WHEN current_streak + 1 >= 3 THEN 1.10
                        ELSE 1.00
                    END,
                    longest_streak = GREATEST(longest_streak, current_streak + 1),
                    updated_at = NOW()
                WHERE child_id = NEW.child_id
                RETURNING streak_multiplier INTO bonus_multiplier;
            ELSE
                -- Streak broken, reset
                UPDATE public.tidy_streaks 
                SET current_streak = 1,
                    last_activity_date = CURRENT_DATE,
                    streak_multiplier = 1.00,
                    updated_at = NOW()
                WHERE child_id = NEW.child_id;
                bonus_multiplier := 1.00;
            END IF;
        END IF;
        
        -- Calculate final points with bonus
        final_points := (NEW.points * bonus_multiplier)::INTEGER;
        
        -- Update child points
        UPDATE public.tidy_children 
        SET total_points = total_points + final_points,
            available_points = available_points + final_points,
            total_xp = total_xp + (final_points / 2),
            updated_at = NOW()
        WHERE id = NEW.child_id;
        
        -- Log points
        INSERT INTO public.tidy_points_log (child_id, points, balance_after, type, description, task_id)
        SELECT NEW.child_id, final_points, available_points + final_points, 'task_complete', 
               'Completed: ' || NEW.title, NEW.id
        FROM public.tidy_children WHERE id = NEW.child_id;
        
        -- Update room zone score
        UPDATE public.tidy_rooms
        SET zone_bed = CASE WHEN NEW.zone = 'bed' THEN LEAST(100, zone_bed + 20) ELSE zone_bed END,
            zone_floor = CASE WHEN NEW.zone = 'floor' THEN LEAST(100, zone_floor + 20) ELSE zone_floor END,
            zone_desk = CASE WHEN NEW.zone = 'desk' THEN LEAST(100, zone_desk + 20) ELSE zone_desk END,
            zone_closet = CASE WHEN NEW.zone = 'closet' THEN LEAST(100, zone_closet + 20) ELSE zone_closet END,
            zone_general = CASE WHEN NEW.zone = 'general' THEN LEAST(100, zone_general + 20) ELSE zone_general END,
            last_cleaned_at = NOW()
        WHERE child_id = NEW.child_id;
        
        NEW.completed_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for task completion
DROP TRIGGER IF EXISTS trigger_task_completion ON public.tidy_tasks;
CREATE TRIGGER trigger_task_completion
    BEFORE UPDATE OF status
    ON public.tidy_tasks
    FOR EACH ROW
    EXECUTE FUNCTION handle_task_completion();

-- Function to create room when child is created
CREATE OR REPLACE FUNCTION create_child_room()
RETURNS TRIGGER AS $$
DECLARE
    default_theme_id UUID;
BEGIN
    -- Get default theme
    SELECT id INTO default_theme_id FROM public.tidy_themes WHERE is_default = TRUE LIMIT 1;
    
    -- Create room
    INSERT INTO public.tidy_rooms (child_id, theme_id)
    VALUES (NEW.id, default_theme_id);
    
    -- Create streak record
    INSERT INTO public.tidy_streaks (child_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create room for new child
DROP TRIGGER IF EXISTS trigger_create_child_room ON public.tidy_children;
CREATE TRIGGER trigger_create_child_room
    AFTER INSERT ON public.tidy_children
    FOR EACH ROW
    EXECUTE FUNCTION create_child_room();

-- Function to decay room cleanliness daily
CREATE OR REPLACE FUNCTION decay_room_cleanliness()
RETURNS void AS $$
BEGIN
    UPDATE public.tidy_rooms
    SET zone_bed = GREATEST(0, zone_bed - 5),
        zone_floor = GREATEST(0, zone_floor - 8),
        zone_desk = GREATEST(0, zone_desk - 5),
        zone_closet = GREATEST(0, zone_closet - 3),
        zone_general = GREATEST(0, zone_general - 5)
    WHERE last_cleaned_at < NOW() - INTERVAL '1 day'
       OR last_cleaned_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.tidy_families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_recurring_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_points_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_child_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_activity_log ENABLE ROW LEVEL SECURITY;

-- Public read access for themes, decorations, achievements, levels, templates
ALTER TABLE public.tidy_themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_decorations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tidy_task_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access for themes" ON public.tidy_themes FOR SELECT USING (true);
CREATE POLICY "Public read access for decorations" ON public.tidy_decorations FOR SELECT USING (true);
CREATE POLICY "Public read access for achievements" ON public.tidy_achievements FOR SELECT USING (true);
CREATE POLICY "Public read access for levels" ON public.tidy_levels FOR SELECT USING (true);
CREATE POLICY "Public read access for task templates" ON public.tidy_task_templates FOR SELECT USING (true);

-- Profiles policy
CREATE POLICY "Users can view own profile" ON public.tidy_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.tidy_profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.tidy_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Family members can view family data
CREATE POLICY "Family members can view family" ON public.tidy_families FOR SELECT 
    USING (id IN (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid()));
CREATE POLICY "Parents can update family" ON public.tidy_families FOR UPDATE 
    USING (id IN (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid() AND role = 'parent'));
CREATE POLICY "Authenticated users can create family" ON public.tidy_families FOR INSERT 
    WITH CHECK (auth.uid() = created_by);

-- Children policies
CREATE POLICY "Family can view children" ON public.tidy_children FOR SELECT 
    USING (family_id IN (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid()));
CREATE POLICY "Parents can manage children" ON public.tidy_children FOR ALL 
    USING (family_id IN (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid() AND role = 'parent'));

-- Rooms policies
CREATE POLICY "Family can view rooms" ON public.tidy_rooms FOR SELECT 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid())));
CREATE POLICY "Family can update rooms" ON public.tidy_rooms FOR UPDATE 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid())));

-- Tasks policies
CREATE POLICY "Family can view tasks" ON public.tidy_tasks FOR SELECT 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid())));
CREATE POLICY "Parents can manage tasks" ON public.tidy_tasks FOR ALL 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid() AND role = 'parent')));
CREATE POLICY "Children can update own tasks" ON public.tidy_tasks FOR UPDATE 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE profile_id = auth.uid()));

-- Points log policies
CREATE POLICY "Family can view points log" ON public.tidy_points_log FOR SELECT 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid())));

-- Streaks policies
CREATE POLICY "Family can view streaks" ON public.tidy_streaks FOR SELECT 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid())));

-- Inventory policies
CREATE POLICY "Family can view inventory" ON public.tidy_inventory FOR SELECT 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE family_id IN 
        (SELECT family_id FROM public.tidy_profiles WHERE id = auth.uid())));
CREATE POLICY "Children can manage own inventory" ON public.tidy_inventory FOR ALL 
    USING (child_id IN (SELECT id FROM public.tidy_children WHERE profile_id = auth.uid()));

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.tidy_notifications FOR SELECT 
    USING (user_id = auth.uid());
CREATE POLICY "Users can update own notifications" ON public.tidy_notifications FOR UPDATE 
    USING (user_id = auth.uid());

-- =====================================================
-- STORAGE BUCKET SETUP
-- =====================================================
-- Run these in Supabase Dashboard > Storage

-- Create bucket: tidy-room-assets
-- Make it public for avatars and previews

-- Storage policies to add via Dashboard:
-- 1. Allow authenticated users to upload to 'avatars/' folder
-- 2. Allow authenticated users to upload to 'verification-photos/' folder
-- 3. Allow public read access to all files

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_tidy_profiles_family ON public.tidy_profiles(family_id);
CREATE INDEX IF NOT EXISTS idx_tidy_children_family ON public.tidy_children(family_id);
CREATE INDEX IF NOT EXISTS idx_tidy_children_profile ON public.tidy_children(profile_id);
CREATE INDEX IF NOT EXISTS idx_tidy_tasks_child ON public.tidy_tasks(child_id);
CREATE INDEX IF NOT EXISTS idx_tidy_tasks_status ON public.tidy_tasks(status);
CREATE INDEX IF NOT EXISTS idx_tidy_tasks_due_date ON public.tidy_tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tidy_points_log_child ON public.tidy_points_log(child_id);
CREATE INDEX IF NOT EXISTS idx_tidy_inventory_child ON public.tidy_inventory(child_id);
CREATE INDEX IF NOT EXISTS idx_tidy_notifications_user ON public.tidy_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_tidy_activity_family ON public.tidy_activity_log(family_id);

-- =====================================================
-- COMPLETE! 🎉
-- =====================================================
-- Your Tidy Room Simulator database is ready!
-- 
-- Next steps:
-- 1. Run this script in Supabase SQL Editor
-- 2. Create storage bucket 'tidy-room-assets' in Storage
-- 3. Set storage policies for file uploads
-- =====================================================
