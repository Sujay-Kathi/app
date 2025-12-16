export type Json =
    | string
    | number
    | boolean
    | null
    | { [key: string]: Json | undefined }
    | Json[]

export interface Database {
    public: {
        Tables: {
            tidy_families: {
                Row: {
                    id: string
                    name: string
                    invite_code: string | null
                    created_by: string | null
                    created_at: string
                    updated_at: string
                }
                Insert: {
                    id?: string
                    name: string
                    invite_code?: string | null
                    created_by?: string | null
                    created_at?: string
                    updated_at?: string
                }
                Update: {
                    id?: string
                    name?: string
                    invite_code?: string | null
                    created_by?: string | null
                    created_at?: string
                    updated_at?: string
                }
            }
            tidy_profiles: {
                Row: {
                    id: string
                    family_id: string | null
                    email: string | null
                    display_name: string
                    avatar_url: string | null
                    role: 'parent' | 'child'
                    is_primary_parent: boolean
                    created_at: string
                    updated_at: string
                }
                Insert: {
                    id: string
                    family_id?: string | null
                    email?: string | null
                    display_name: string
                    avatar_url?: string | null
                    role?: 'parent' | 'child'
                    is_primary_parent?: boolean
                    created_at?: string
                    updated_at?: string
                }
                Update: {
                    id?: string
                    family_id?: string | null
                    email?: string | null
                    display_name?: string
                    avatar_url?: string | null
                    role?: 'parent' | 'child'
                    is_primary_parent?: boolean
                    created_at?: string
                    updated_at?: string
                }
            }
            tidy_children: {
                Row: {
                    id: string
                    profile_id: string | null
                    family_id: string | null
                    name: string
                    age: number | null
                    avatar_emoji: string
                    pin_code: string | null
                    total_points: number
                    available_points: number
                    current_level: number
                    total_xp: number
                    created_at: string
                    updated_at: string
                }
                Insert: {
                    id?: string
                    profile_id?: string | null
                    family_id?: string | null
                    name: string
                    age?: number | null
                    avatar_emoji?: string
                    pin_code?: string | null
                    total_points?: number
                    available_points?: number
                    current_level?: number
                    total_xp?: number
                    created_at?: string
                    updated_at?: string
                }
                Update: {
                    id?: string
                    profile_id?: string | null
                    family_id?: string | null
                    name?: string
                    age?: number | null
                    avatar_emoji?: string
                    pin_code?: string | null
                    total_points?: number
                    available_points?: number
                    current_level?: number
                    total_xp?: number
                    created_at?: string
                    updated_at?: string
                }
            }
            tidy_rooms: {
                Row: {
                    id: string
                    child_id: string | null
                    theme_id: string | null
                    cleanliness_score: number
                    zone_bed: number
                    zone_floor: number
                    zone_desk: number
                    zone_closet: number
                    zone_general: number
                    last_cleaned_at: string | null
                    created_at: string
                    updated_at: string
                }
                Insert: {
                    id?: string
                    child_id?: string | null
                    theme_id?: string | null
                    cleanliness_score?: number
                    zone_bed?: number
                    zone_floor?: number
                    zone_desk?: number
                    zone_closet?: number
                    zone_general?: number
                    last_cleaned_at?: string | null
                    created_at?: string
                    updated_at?: string
                }
                Update: {
                    id?: string
                    child_id?: string | null
                    theme_id?: string | null
                    cleanliness_score?: number
                    zone_bed?: number
                    zone_floor?: number
                    zone_desk?: number
                    zone_closet?: number
                    zone_general?: number
                    last_cleaned_at?: string | null
                    created_at?: string
                    updated_at?: string
                }
            }
            tidy_tasks: {
                Row: {
                    id: string
                    child_id: string
                    created_by: string | null
                    template_id: string | null
                    title: string
                    description: string | null
                    zone: 'bed' | 'floor' | 'desk' | 'closet' | 'general'
                    points: number
                    difficulty: 'easy' | 'medium' | 'hard'
                    icon: string
                    frequency: 'daily' | 'weekly' | 'one_time'
                    status: 'pending' | 'completed' | 'verified' | 'rejected' | 'expired'
                    due_date: string | null
                    requires_verification: boolean
                    verification_photo_url: string | null
                    completed_at: string | null
                    verified_at: string | null
                    verified_by: string | null
                    rejection_reason: string | null
                    created_at: string
                    updated_at: string
                }
                Insert: {
                    id?: string
                    child_id: string
                    created_by?: string | null
                    template_id?: string | null
                    title: string
                    description?: string | null
                    zone: 'bed' | 'floor' | 'desk' | 'closet' | 'general'
                    points: number
                    difficulty?: 'easy' | 'medium' | 'hard'
                    icon?: string
                    frequency?: 'daily' | 'weekly' | 'one_time'
                    status?: 'pending' | 'completed' | 'verified' | 'rejected' | 'expired'
                    due_date?: string | null
                    requires_verification?: boolean
                    verification_photo_url?: string | null
                    completed_at?: string | null
                    verified_at?: string | null
                    verified_by?: string | null
                    rejection_reason?: string | null
                    created_at?: string
                    updated_at?: string
                }
                Update: {
                    id?: string
                    child_id?: string
                    created_by?: string | null
                    template_id?: string | null
                    title?: string
                    description?: string | null
                    zone?: 'bed' | 'floor' | 'desk' | 'closet' | 'general'
                    points?: number
                    difficulty?: 'easy' | 'medium' | 'hard'
                    icon?: string
                    frequency?: 'daily' | 'weekly' | 'one_time'
                    status?: 'pending' | 'completed' | 'verified' | 'rejected' | 'expired'
                    due_date?: string | null
                    requires_verification?: boolean
                    verification_photo_url?: string | null
                    completed_at?: string | null
                    verified_at?: string | null
                    verified_by?: string | null
                    rejection_reason?: string | null
                    created_at?: string
                    updated_at?: string
                }
            }
            tidy_themes: {
                Row: {
                    id: string
                    name: string
                    description: string | null
                    preview_url: string | null
                    price: number
                    is_default: boolean
                    is_premium: boolean
                    colors: Json
                    assets: Json
                    unlock_level: number
                    created_at: string
                }
                Insert: {
                    id?: string
                    name: string
                    description?: string | null
                    preview_url?: string | null
                    price?: number
                    is_default?: boolean
                    is_premium?: boolean
                    colors?: Json
                    assets?: Json
                    unlock_level?: number
                    created_at?: string
                }
                Update: {
                    id?: string
                    name?: string
                    description?: string | null
                    preview_url?: string | null
                    price?: number
                    is_default?: boolean
                    is_premium?: boolean
                    colors?: Json
                    assets?: Json
                    unlock_level?: number
                    created_at?: string
                }
            }
            tidy_decorations: {
                Row: {
                    id: string
                    name: string
                    description: string | null
                    category: 'wall' | 'furniture' | 'accessory' | 'effect' | 'pet'
                    zone: 'bed' | 'floor' | 'desk' | 'closet' | 'general' | 'any' | null
                    preview_url: string | null
                    asset_url: string | null
                    price: number
                    is_premium: boolean
                    unlock_level: number
                    position_data: Json
                    created_at: string
                }
                Insert: {
                    id?: string
                    name: string
                    description?: string | null
                    category: 'wall' | 'furniture' | 'accessory' | 'effect' | 'pet'
                    zone?: 'bed' | 'floor' | 'desk' | 'closet' | 'general' | 'any' | null
                    preview_url?: string | null
                    asset_url?: string | null
                    price?: number
                    is_premium?: boolean
                    unlock_level?: number
                    position_data?: Json
                    created_at?: string
                }
                Update: {
                    id?: string
                    name?: string
                    description?: string | null
                    category?: 'wall' | 'furniture' | 'accessory' | 'effect' | 'pet'
                    zone?: 'bed' | 'floor' | 'desk' | 'closet' | 'general' | 'any' | null
                    preview_url?: string | null
                    asset_url?: string | null
                    price?: number
                    is_premium?: boolean
                    unlock_level?: number
                    position_data?: Json
                    created_at?: string
                }
            }
            tidy_streaks: {
                Row: {
                    id: string
                    child_id: string
                    current_streak: number
                    longest_streak: number
                    last_activity_date: string | null
                    streak_multiplier: number
                    created_at: string
                    updated_at: string
                }
                Insert: {
                    id?: string
                    child_id: string
                    current_streak?: number
                    longest_streak?: number
                    last_activity_date?: string | null
                    streak_multiplier?: number
                    created_at?: string
                    updated_at?: string
                }
                Update: {
                    id?: string
                    child_id?: string
                    current_streak?: number
                    longest_streak?: number
                    last_activity_date?: string | null
                    streak_multiplier?: number
                    created_at?: string
                    updated_at?: string
                }
            }
            tidy_points_log: {
                Row: {
                    id: string
                    child_id: string
                    points: number
                    balance_after: number
                    type: 'task_complete' | 'streak_bonus' | 'level_up' | 'purchase' | 'adjustment' | 'bonus'
                    description: string
                    task_id: string | null
                    created_at: string
                }
                Insert: {
                    id?: string
                    child_id: string
                    points: number
                    balance_after: number
                    type: 'task_complete' | 'streak_bonus' | 'level_up' | 'purchase' | 'adjustment' | 'bonus'
                    description: string
                    task_id?: string | null
                    created_at?: string
                }
                Update: {
                    id?: string
                    child_id?: string
                    points?: number
                    balance_after?: number
                    type?: 'task_complete' | 'streak_bonus' | 'level_up' | 'purchase' | 'adjustment' | 'bonus'
                    description?: string
                    task_id?: string | null
                    created_at?: string
                }
            }
            tidy_inventory: {
                Row: {
                    id: string
                    child_id: string
                    item_id: string
                    item_type: 'theme' | 'decoration'
                    is_equipped: boolean
                    position: Json
                    purchased_at: string
                }
                Insert: {
                    id?: string
                    child_id: string
                    item_id: string
                    item_type: 'theme' | 'decoration'
                    is_equipped?: boolean
                    position?: Json
                    purchased_at?: string
                }
                Update: {
                    id?: string
                    child_id?: string
                    item_id?: string
                    item_type?: 'theme' | 'decoration'
                    is_equipped?: boolean
                    position?: Json
                    purchased_at?: string
                }
            }
            tidy_achievements: {
                Row: {
                    id: string
                    name: string
                    description: string
                    icon: string
                    category: 'streak' | 'tasks' | 'points' | 'level' | 'special' | null
                    requirement_type: string
                    requirement_value: number
                    xp_reward: number
                    points_reward: number
                    created_at: string
                }
                Insert: {
                    id?: string
                    name: string
                    description: string
                    icon?: string
                    category?: 'streak' | 'tasks' | 'points' | 'level' | 'special' | null
                    requirement_type: string
                    requirement_value: number
                    xp_reward?: number
                    points_reward?: number
                    created_at?: string
                }
                Update: {
                    id?: string
                    name?: string
                    description?: string
                    icon?: string
                    category?: 'streak' | 'tasks' | 'points' | 'level' | 'special' | null
                    requirement_type?: string
                    requirement_value?: number
                    xp_reward?: number
                    points_reward?: number
                    created_at?: string
                }
            }
            tidy_levels: {
                Row: {
                    level: number
                    title: string
                    xp_required: number
                    icon: string
                    rewards: Json
                    created_at: string
                }
                Insert: {
                    level: number
                    title: string
                    xp_required: number
                    icon?: string
                    rewards?: Json
                    created_at?: string
                }
                Update: {
                    level?: number
                    title?: string
                    xp_required?: number
                    icon?: string
                    rewards?: Json
                    created_at?: string
                }
            }
            tidy_task_templates: {
                Row: {
                    id: string
                    title: string
                    description: string | null
                    zone: 'bed' | 'floor' | 'desk' | 'closet' | 'general'
                    default_points: number
                    difficulty: 'easy' | 'medium' | 'hard'
                    icon: string
                    estimated_minutes: number
                    is_system: boolean
                    created_at: string
                }
                Insert: {
                    id?: string
                    title: string
                    description?: string | null
                    zone: 'bed' | 'floor' | 'desk' | 'closet' | 'general'
                    default_points?: number
                    difficulty?: 'easy' | 'medium' | 'hard'
                    icon?: string
                    estimated_minutes?: number
                    is_system?: boolean
                    created_at?: string
                }
                Update: {
                    id?: string
                    title?: string
                    description?: string | null
                    zone?: 'bed' | 'floor' | 'desk' | 'closet' | 'general'
                    default_points?: number
                    difficulty?: 'easy' | 'medium' | 'hard'
                    icon?: string
                    estimated_minutes?: number
                    is_system?: boolean
                    created_at?: string
                }
            }
        }
    }
}

// Convenience types
export type Family = Database['public']['Tables']['tidy_families']['Row'];
export type Profile = Database['public']['Tables']['tidy_profiles']['Row'];
export type Child = Database['public']['Tables']['tidy_children']['Row'];
export type Room = Database['public']['Tables']['tidy_rooms']['Row'];
export type Task = Database['public']['Tables']['tidy_tasks']['Row'];
export type Theme = Database['public']['Tables']['tidy_themes']['Row'];
export type Decoration = Database['public']['Tables']['tidy_decorations']['Row'];
export type Streak = Database['public']['Tables']['tidy_streaks']['Row'];
export type PointsLog = Database['public']['Tables']['tidy_points_log']['Row'];
export type Inventory = Database['public']['Tables']['tidy_inventory']['Row'];
export type Achievement = Database['public']['Tables']['tidy_achievements']['Row'];
export type Level = Database['public']['Tables']['tidy_levels']['Row'];
export type TaskTemplate = Database['public']['Tables']['tidy_task_templates']['Row'];

// Zone type
export type Zone = 'bed' | 'floor' | 'desk' | 'closet' | 'general';

// Extended types with relations
export interface ChildWithRoom extends Child {
    room: Room | null;
    streak: Streak | null;
}

export interface TaskWithChild extends Task {
    child: Child | null;
}
