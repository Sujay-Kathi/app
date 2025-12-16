# 🏠 Tidy Room Simulator
## Project Requirements Document (PRD)

---

**Version:** 1.0  
**Date:** December 16, 2024  
**Project Type:** IDT (Interdisciplinary) Project  
**Document Status:** Draft - Awaiting Approval

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Overview](#2-project-overview)
3. [Target Audience](#3-target-audience)
4. [Core Features](#4-core-features)
5. [Functional Requirements](#5-functional-requirements)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [User Stories](#7-user-stories)
8. [Technical Architecture](#8-technical-architecture)
9. [Database Schema](#9-database-schema)
10. [API Specifications](#10-api-specifications)
11. [UI/UX Requirements](#11-uiux-requirements)
12. [Security Requirements](#12-security-requirements)
13. [Implementation Phases](#13-implementation-phases)
14. [Success Metrics](#14-success-metrics)
15. [Risks & Mitigation](#15-risks--mitigation)
16. [Future Scope](#16-future-scope)

---

## 1. Executive Summary

### 1.1 Project Vision
**Tidy Room Simulator** is a gamified mobile/web application designed to make cleaning enjoyable for children aged 6-12 by creating a virtual representation of their room that transforms as they complete real-world cleaning tasks.

### 1.2 Problem Statement
- Children find cleaning boring and avoid household chores
- Parents struggle to motivate children to maintain clean rooms
- Traditional reward systems (nagging, punishment) are ineffective
- Missed opportunity to build lifelong cleanliness habits early

### 1.3 Solution
A digital twin of the child's room that:
- Starts in a "messy" state
- Transforms with satisfying animations as real-world tasks are completed
- Rewards consistent cleaning with virtual decorations and customizations
- Provides parents with oversight and task management tools

### 1.4 Key Success Factors
- Engaging, child-friendly UI with appealing animations
- Simple task verification system
- Meaningful reward/progression system
- Minimal friction for daily use

---

## 2. Project Overview

### 2.1 Application Type
| Platform | Technology | Status |
|----------|------------|--------|
| Web App | Next.js / React | Primary |
| Mobile (iOS/Android) | Flutter / React Native | Phase 2 |
| PWA Support | Service Workers | Yes |

### 2.2 Core Concept
```
[ Real Room (Messy) ] ─── Child Cleans ─── [ Virtual Room Transforms ]
         │                                            │
         │                                            ▼
         │                              [ Earn Points & Decorations ]
         │                                            │
         ▼                                            ▼
[ Parent Assigns Tasks ] ◄──── [ Progress Dashboard ] ────► [ Rewards Store ]
```

### 2.3 Stakeholders
| Role | Description | Needs |
|------|-------------|-------|
| Child (6-12 years) | Primary user | Fun, rewards, visual feedback |
| Parent/Guardian | Task manager | Easy oversight, task assignment |
| Administrator | System admin | Analytics, content management |

---

## 3. Target Audience

### 3.1 Primary Users: Children
| Attribute | Details |
|-----------|---------|
| Age Range | 6-12 years old |
| Tech Comfort | Basic smartphone/tablet usage |
| Attention Span | Short (needs immediate feedback) |
| Motivation | Games, rewards, visual progress |

### 3.2 Secondary Users: Parents
| Attribute | Details |
|-----------|---------|
| Age Range | 25-45 years old |
| Tech Comfort | Moderate to high |
| Pain Points | Motivating children, tracking progress |
| Goals | Teach responsibility, reduce nagging |

### 3.3 User Personas

#### Persona 1: Arjun (Age 8)
- **Background:** 3rd grade student, loves video games
- **Goal:** Earn enough points to unlock the "Space Theme" for his room
- **Frustration:** Cleaning is boring, prefers playing
- **Motivation:** Seeing his virtual room transform like a game level

#### Persona 2: Priya (Age 11)
- **Background:** 6th grader, creative and organized
- **Goal:** Have the "best decorated" virtual room among friends
- **Frustration:** Parents always telling her to clean
- **Motivation:** Social validation, creative expression

#### Persona 3: Mrs. Sharma (Parent)
- **Background:** Working mother of two
- **Goal:** Get children to clean without constant reminders
- **Frustration:** Daily battles over room cleanliness
- **Motivation:** Peaceful home, teaching responsibility

---

## 4. Core Features

### 4.1 Feature Priority Matrix

| Feature | Priority | Complexity | Phase |
|---------|----------|------------|-------|
| Virtual Room Display | 🔴 Critical | Medium | 1 |
| Task Management | 🔴 Critical | Low | 1 |
| Room Transformation | 🔴 Critical | High | 1 |
| Points System | 🔴 Critical | Low | 1 |
| User Authentication | 🔴 Critical | Medium | 1 |
| Parent Dashboard | 🔴 Critical | Medium | 1 |
| Rewards Store | 🟡 High | Medium | 1 |
| Virtual Pet | 🟡 High | Medium | 2 |
| Photo Verification | 🟡 High | High | 2 |
| Room Themes | 🟢 Medium | Medium | 2 |
| Social Features | 🟢 Medium | High | 3 |
| AI Cleanliness Detection | 🔵 Low | Very High | 3 |

### 4.2 MVP (Minimum Viable Product) Features
1. ✅ User registration & login (Parent + Child accounts)
2. ✅ Virtual room with messy/clean states
3. ✅ Task list with point values
4. ✅ Task completion (manual check-off)
5. ✅ Points & basic rewards
6. ✅ Room cleanliness score (0-100%)
7. ✅ Parent task assignment
8. ✅ Basic room decoration store

---

## 5. Functional Requirements

### 5.1 Authentication & User Management

#### FR-1.1: User Registration
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1.1.1 | Parent can create a family account | Critical |
| FR-1.1.2 | Parent can add child profiles | Critical |
| FR-1.1.3 | Each child has unique login (PIN or password) | Critical |
| FR-1.1.4 | Email verification for parent account | High |
| FR-1.1.5 | Password reset functionality | High |

#### FR-1.2: User Roles
| Role | Permissions |
|------|-------------|
| Parent | Full access: create tasks, view progress, manage rewards, edit profiles |
| Child | Limited: view tasks, mark complete, spend points, customize room |

### 5.2 Virtual Room System

#### FR-2.1: Room Display
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-2.1.1 | Display 2D/isometric view of room | Critical |
| FR-2.1.2 | Room divided into zones (Bed, Desk, Floor, Closet) | Critical |
| FR-2.1.3 | Visual state changes based on cleanliness | Critical |
| FR-2.1.4 | Smooth transition animations | High |
| FR-2.1.5 | Responsive design for different screens | High |

#### FR-2.2: Room States
| State | Cleanliness % | Visual Description |
|-------|---------------|---------------------|
| Pristine | 90-100% | Sparkles, bright lighting, organized |
| Clean | 70-89% | Tidy, normal lighting |
| Messy | 40-69% | Some clutter visible, items displaced |
| Very Messy | 20-39% | Significant clutter, dim lighting |
| Disaster | 0-19% | Chaos, items everywhere, dark |

#### FR-2.3: Room Zones
| Zone | Example Tasks | Weight |
|------|---------------|--------|
| Bed Zone | Make bed, change sheets | 25% |
| Floor Zone | Pick up items, vacuum | 25% |
| Desk Zone | Organize papers, clear clutter | 20% |
| Closet Zone | Hang clothes, organize | 20% |
| General | Dust, general tidying | 10% |

### 5.3 Task Management

#### FR-3.1: Task Properties
```
Task {
  id: string
  title: string (e.g., "Make the Bed")
  description: string
  zone: enum (BED, FLOOR, DESK, CLOSET, GENERAL)
  points: number (10-100)
  difficulty: enum (EASY, MEDIUM, HARD)
  frequency: enum (DAILY, WEEKLY, ONE_TIME)
  assignedTo: childId
  dueDate: datetime (optional)
  status: enum (PENDING, COMPLETED, VERIFIED, EXPIRED)
  createdBy: parentId
  completedAt: datetime
  verifiedAt: datetime
}
```

#### FR-3.2: Task Operations
| ID | Requirement | Actor |
|----|-------------|-------|
| FR-3.2.1 | Create new task | Parent |
| FR-3.2.2 | Edit existing task | Parent |
| FR-3.2.3 | Delete task | Parent |
| FR-3.2.4 | View assigned tasks | Child |
| FR-3.2.5 | Mark task as complete | Child |
| FR-3.2.6 | Verify task completion | Parent (optional) |
| FR-3.2.7 | View task history | Both |

#### FR-3.3: Pre-defined Task Templates
| Task | Zone | Points | Difficulty |
|------|------|--------|------------|
| Make the bed | Bed | 15 | Easy |
| Change bed sheets | Bed | 40 | Medium |
| Pick up toys from floor | Floor | 20 | Easy |
| Vacuum the floor | Floor | 50 | Hard |
| Clear desk clutter | Desk | 25 | Medium |
| Organize bookshelf | Desk | 35 | Medium |
| Put away clean clothes | Closet | 30 | Medium |
| Organize closet | Closet | 60 | Hard |
| Dust surfaces | General | 30 | Medium |
| Empty trash bin | General | 10 | Easy |

### 5.4 Points & Rewards System

#### FR-4.1: Points Economy
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-4.1.1 | Earn points for completing tasks | Critical |
| FR-4.1.2 | Bonus points for streaks | High |
| FR-4.1.3 | Points visible on main screen | Critical |
| FR-4.1.4 | Transaction history | Medium |

#### FR-4.2: Streak System
| Streak Length | Bonus |
|---------------|-------|
| 3 days | +10% bonus on all tasks |
| 7 days | +25% bonus on all tasks |
| 14 days | +50% bonus on all tasks |
| 30 days | +100% bonus on all tasks |

#### FR-4.3: Rewards Store
| Category | Examples | Point Range |
|----------|----------|-------------|
| Wall Decorations | Posters, paintings, wallpapers | 50-200 |
| Furniture Accessories | Bed covers, rugs, lamps | 100-300 |
| Room Themes | Space, Ocean, Jungle, Gaming | 500-1000 |
| Pets | Cat, Dog, Hamster (animated) | 300-500 |
| Special Effects | Sparkles, rainbow, glow | 200-400 |

### 5.5 Parent Dashboard

#### FR-5.1: Dashboard Features
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-5.1.1 | View all children's progress | Critical |
| FR-5.1.2 | Task completion statistics | High |
| FR-5.1.3 | Weekly/monthly reports | Medium |
| FR-5.1.4 | Assign tasks to specific child | Critical |
| FR-5.1.5 | Set up recurring tasks | High |
| FR-5.1.6 | Approve/verify task completion | High |
| FR-5.1.7 | Manage rewards/point adjustments | Medium |

---

## 6. Non-Functional Requirements

### 6.1 Performance
| Requirement | Target |
|-------------|--------|
| Page Load Time | < 3 seconds |
| Animation Frame Rate | 60 FPS |
| API Response Time | < 500ms |
| Time to Interactive | < 5 seconds |

### 6.2 Scalability
| Requirement | Target |
|-------------|--------|
| Concurrent Users | 1,000+ |
| Database Size | 100,000+ users |
| Storage per User | ~50MB (images, data) |

### 6.3 Availability
| Requirement | Target |
|-------------|--------|
| Uptime | 99.5% |
| Planned Maintenance | < 4 hours/month |
| Data Backup | Daily automated |

### 6.4 Compatibility
| Platform | Requirement |
|----------|-------------|
| Browsers | Chrome 90+, Firefox 88+, Safari 14+, Edge 90+ |
| Mobile | iOS 13+, Android 8+ |
| Screen Sizes | 320px - 2560px width |

### 6.5 Accessibility
| Requirement | Standard |
|-------------|----------|
| Color Contrast | WCAG 2.1 AA |
| Screen Reader | Basic support |
| Keyboard Navigation | Full support |
| Font Scaling | Up to 200% |

---

## 7. User Stories

### 7.1 Child User Stories

```
US-C01: As a child, I want to see my virtual room so I know what state it's in
  Acceptance Criteria:
  - Room displays on home screen after login
  - Visual state matches current cleanliness score
  - Zones are clearly visible

US-C02: As a child, I want to view my daily tasks so I know what needs to be done
  Acceptance Criteria:
  - Task list shows all pending tasks
  - Each task shows points value
  - Tasks sorted by due date/priority

US-C03: As a child, I want to mark a task as complete so I can earn points
  Acceptance Criteria:
  - One-tap completion
  - Immediate point award
  - Room animation shows improvement
  - Celebration animation/sound

US-C04: As a child, I want to spend points in the store so I can decorate my room
  Acceptance Criteria:
  - Browse available decorations
  - See point cost for each item
  - Purchase confirmation
  - Item appears in room immediately

US-C05: As a child, I want to maintain a streak so I get bonus points
  Acceptance Criteria:
  - Streak counter visible on home screen
  - Notification when streak at risk
  - Bonus multiplier clearly shown

US-C06: As a child, I want to see my progress level so I feel accomplished
  Acceptance Criteria:
  - Level displayed prominently
  - Progress bar to next level
  - Level-up celebration animation
```

### 7.2 Parent User Stories

```
US-P01: As a parent, I want to create an account so my family can use the app
  Acceptance Criteria:
  - Simple registration flow
  - Email verification
  - Can add multiple children

US-P02: As a parent, I want to add my child's profile so they can use the app
  Acceptance Criteria:
  - Enter child's name, age, avatar
  - Set child's login PIN
  - Link to parent account

US-P03: As a parent, I want to assign tasks to my child so they know what to clean
  Acceptance Criteria:
  - Select from templates or create custom
  - Set point value
  - Assign to specific child
  - Set frequency (daily/weekly/one-time)

US-P04: As a parent, I want to view my child's progress so I can track their efforts
  Acceptance Criteria:
  - See completion rate
  - View streak information
  - Weekly summary available

US-P05: As a parent, I want to verify task completion so I can ensure quality
  Acceptance Criteria:
  - Notification when child marks complete
  - Option to approve or request redo
  - Points only awarded after approval (if enabled)

US-P06: As a parent, I want to set up recurring tasks so I don't have to create them daily
  Acceptance Criteria:
  - Select frequency (daily, weekly, specific days)
  - Auto-creates tasks on schedule
  - Can edit recurring pattern
```

---

## 8. Technical Architecture

### 8.1 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │   Web App   │  │  iOS App    │  │ Android App │                  │
│  │  (Next.js)  │  │  (Flutter)  │  │  (Flutter)  │                  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                  │
│         └────────────────┼────────────────┘                         │
│                          ▼                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    API GATEWAY                               │   │
│  │                  (REST / GraphQL)                            │   │
│  └─────────────────────────┬───────────────────────────────────┘   │
└────────────────────────────┼────────────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────────────┐
│                         BACKEND LAYER                               │
├────────────────────────────┼────────────────────────────────────────┤
│                            ▼                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                APPLICATION SERVER                            │   │
│  │              (Node.js / Supabase Edge Functions)             │   │
│  └──────┬──────────────────┬───────────────────┬───────────────┘   │
│         │                  │                   │                    │
│         ▼                  ▼                   ▼                    │
│  ┌───────────┐     ┌───────────────┐   ┌─────────────┐             │
│  │   Auth    │     │  Business     │   │ Notification │             │
│  │  Service  │     │    Logic      │   │   Service    │             │
│  │ (Supabase)│     │   Service     │   │ (Push/Email) │             │
│  └───────────┘     └───────────────┘   └─────────────┘             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────────────┐
│                         DATA LAYER                                  │
├────────────────────────────┼────────────────────────────────────────┤
│         ┌──────────────────┴──────────────────┐                     │
│         ▼                                     ▼                     │
│  ┌─────────────────┐               ┌─────────────────┐              │
│  │    Supabase     │               │  Cloud Storage  │              │
│  │   PostgreSQL    │               │   (Images)      │              │
│  │    Database     │               │  Supabase/AWS   │              │
│  └─────────────────┘               └─────────────────┘              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.2 Technology Stack

| Layer | Technology | Justification |
|-------|------------|---------------|
| **Frontend** | Next.js 14 (React) | SSR, great DX, TypeScript support |
| **Styling** | Tailwind CSS + Framer Motion | Rapid UI development, animations |
| **State Management** | Zustand / React Context | Lightweight, easy to use |
| **Backend** | Supabase | PostgreSQL, Auth, Realtime, Storage built-in |
| **Database** | PostgreSQL (via Supabase) | Relational data, ACID compliance |
| **Authentication** | Supabase Auth | Built-in, secure, social logins |
| **File Storage** | Supabase Storage | Integrated, CDN-backed |
| **Hosting** | Vercel | Optimized for Next.js, auto-scaling |
| **Room Graphics** | React + SVG / Canvas | Interactive, animatable |
| **Animations** | Framer Motion + Lottie | Smooth, performant animations |

### 8.3 Frontend Architecture

```
src/
├── app/                          # Next.js app router
│   ├── (auth)/                   # Auth pages
│   │   ├── login/
│   │   ├── register/
│   │   └── forgot-password/
│   ├── (child)/                  # Child interface
│   │   ├── room/                 # Virtual room view
│   │   ├── tasks/                # Task list
│   │   ├── store/                # Rewards store
│   │   └── profile/              # Child profile
│   ├── (parent)/                 # Parent dashboard
│   │   ├── dashboard/            # Overview
│   │   ├── children/             # Manage children
│   │   ├── tasks/                # Task management
│   │   └── reports/              # Progress reports
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── room/                     # Room components
│   │   ├── VirtualRoom.tsx       # Main room component
│   │   ├── RoomZone.tsx          # Zone component
│   │   ├── RoomItem.tsx          # Furniture/decor
│   │   └── RoomAnimation.tsx     # Transformation animations
│   ├── tasks/                    # Task components
│   ├── rewards/                  # Store/rewards
│   ├── ui/                       # Base UI components
│   └── common/                   # Shared components
├── lib/
│   ├── supabase/                 # Supabase client & helpers
│   ├── hooks/                    # Custom React hooks
│   ├── utils/                    # Utility functions
│   └── constants/                # App constants
├── stores/                       # Zustand stores
│   ├── authStore.ts
│   ├── roomStore.ts
│   └── taskStore.ts
├── types/                        # TypeScript types
└── styles/                       # Global styles
```

---

## 9. Database Schema

### 9.1 Entity Relationship Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   FAMILY    │     │    USER     │     │   CHILD     │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id (PK)     │────<│ id (PK)     │────<│ id (PK)     │
│ name        │     │ family_id   │     │ user_id     │
│ created_at  │     │ email       │     │ name        │
│ updated_at  │     │ role        │     │ age         │
└─────────────┘     │ created_at  │     │ avatar      │
                    └─────────────┘     │ pin         │
                                        │ room_id     │
                                        └──────┬──────┘
                                               │
           ┌───────────────────────────────────┼───────────────────────────────────┐
           │                                   │                                   │
           ▼                                   ▼                                   ▼
┌─────────────────┐               ┌─────────────────┐               ┌─────────────────┐
│      ROOM       │               │      TASK       │               │   POINTS_LOG    │
├─────────────────┤               ├─────────────────┤               ├─────────────────┤
│ id (PK)         │               │ id (PK)         │               │ id (PK)         │
│ child_id (FK)   │               │ child_id (FK)   │               │ child_id (FK)   │
│ cleanliness     │               │ title           │               │ points          │
│ theme_id (FK)   │               │ zone            │               │ reason          │
│ decorations[]   │               │ points          │               │ task_id (FK)    │
│ updated_at      │               │ difficulty      │               │ created_at      │
└─────────────────┘               │ frequency       │               └─────────────────┘
                                  │ status          │
                                  │ due_date        │
                                  │ created_by (FK) │
                                  │ completed_at    │
                                  └─────────────────┘

┌─────────────────┐               ┌─────────────────┐               ┌─────────────────┐
│     THEME       │               │   DECORATION    │               │   INVENTORY     │
├─────────────────┤               ├─────────────────┤               ├─────────────────┤
│ id (PK)         │               │ id (PK)         │               │ id (PK)         │
│ name            │               │ name            │               │ child_id (FK)   │
│ preview_url     │               │ category        │               │ item_id (FK)    │
│ price           │               │ preview_url     │               │ item_type       │
│ assets[]        │               │ price           │               │ purchased_at    │
└─────────────────┘               │ zone            │               │ is_equipped     │
                                  └─────────────────┘               └─────────────────┘

┌─────────────────┐
│     STREAK      │
├─────────────────┤
│ id (PK)         │
│ child_id (FK)   │
│ current_streak  │
│ longest_streak  │
│ last_activity   │
└─────────────────┘
```

### 9.2 Table Definitions

```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    family_id UUID REFERENCES families(id),
    role TEXT NOT NULL CHECK (role IN ('parent', 'child')),
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Families table
CREATE TABLE public.families (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Children table (additional child-specific data)
CREATE TABLE public.children (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id) UNIQUE,
    age INTEGER CHECK (age >= 1 AND age <= 18),
    pin TEXT, -- 4-digit PIN for child login
    total_points INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rooms table
CREATE TABLE public.rooms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    child_id UUID REFERENCES children(id) UNIQUE,
    cleanliness INTEGER DEFAULT 0 CHECK (cleanliness >= 0 AND cleanliness <= 100),
    theme_id UUID REFERENCES themes(id),
    zone_bed INTEGER DEFAULT 0,
    zone_floor INTEGER DEFAULT 0,
    zone_desk INTEGER DEFAULT 0,
    zone_closet INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tasks table
CREATE TABLE public.tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    child_id UUID REFERENCES children(id),
    created_by UUID REFERENCES auth.users(id),
    title TEXT NOT NULL,
    description TEXT,
    zone TEXT NOT NULL CHECK (zone IN ('bed', 'floor', 'desk', 'closet', 'general')),
    points INTEGER NOT NULL CHECK (points > 0),
    difficulty TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),
    frequency TEXT DEFAULT 'one_time' CHECK (frequency IN ('daily', 'weekly', 'one_time')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'verified', 'expired')),
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Points log table
CREATE TABLE public.points_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    child_id UUID REFERENCES children(id),
    points INTEGER NOT NULL,
    reason TEXT NOT NULL,
    task_id UUID REFERENCES tasks(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Streaks table
CREATE TABLE public.streaks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    child_id UUID REFERENCES children(id) UNIQUE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Themes table
CREATE TABLE public.themes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    preview_url TEXT,
    price INTEGER NOT NULL,
    assets JSONB, -- Room assets for this theme
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Decorations table
CREATE TABLE public.decorations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT CHECK (category IN ('wall', 'furniture', 'accessory', 'effect')),
    zone TEXT CHECK (zone IN ('bed', 'floor', 'desk', 'closet', 'general', 'any')),
    preview_url TEXT,
    asset_url TEXT,
    price INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory table (purchased items)
CREATE TABLE public.inventory (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    child_id UUID REFERENCES children(id),
    item_id UUID NOT NULL, -- References either theme or decoration
    item_type TEXT CHECK (item_type IN ('theme', 'decoration')),
    is_equipped BOOLEAN DEFAULT FALSE,
    position JSONB, -- Position in room for decorations
    purchased_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, item_id, item_type)
);

-- Task templates table
CREATE TABLE public.task_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    zone TEXT NOT NULL,
    default_points INTEGER NOT NULL,
    difficulty TEXT DEFAULT 'medium',
    icon TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 10. API Specifications

### 10.1 API Endpoints Overview

#### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register parent account |
| POST | `/auth/login` | Parent login |
| POST | `/auth/login/child` | Child login with PIN |
| POST | `/auth/logout` | Logout |
| POST | `/auth/forgot-password` | Request password reset |

#### Children
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/children` | List all children in family |
| POST | `/children` | Create child profile |
| GET | `/children/:id` | Get child details |
| PUT | `/children/:id` | Update child profile |
| DELETE | `/children/:id` | Remove child profile |

#### Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/rooms/:childId` | Get child's room state |
| PUT | `/rooms/:childId` | Update room state |
| GET | `/rooms/:childId/decorations` | Get equipped decorations |
| POST | `/rooms/:childId/decorations` | Equip decoration |

#### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | List tasks (with filters) |
| POST | `/tasks` | Create new task |
| GET | `/tasks/:id` | Get task details |
| PUT | `/tasks/:id` | Update task |
| DELETE | `/tasks/:id` | Delete task |
| POST | `/tasks/:id/complete` | Mark task complete |
| POST | `/tasks/:id/verify` | Verify task (parent) |

#### Store
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/store/themes` | List available themes |
| GET | `/store/decorations` | List decorations |
| POST | `/store/purchase` | Purchase item |
| GET | `/inventory/:childId` | Get child's inventory |

#### Progress
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/progress/:childId` | Get child's progress stats |
| GET | `/progress/:childId/streak` | Get streak information |
| GET | `/progress/:childId/history` | Get points history |

### 10.2 Sample API Response

```json
// GET /rooms/child-uuid-123
{
  "success": true,
  "data": {
    "id": "room-uuid-456",
    "childId": "child-uuid-123",
    "cleanliness": 72,
    "zones": {
      "bed": 85,
      "floor": 60,
      "desk": 75,
      "closet": 70
    },
    "theme": {
      "id": "theme-uuid-789",
      "name": "Space Adventure",
      "previewUrl": "https://..."
    },
    "decorations": [
      {
        "id": "decoration-uuid-001",
        "name": "Rocket Poster",
        "position": { "x": 120, "y": 80 },
        "zone": "wall"
      }
    ],
    "updatedAt": "2024-12-16T10:30:00Z"
  }
}
```

---

## 11. UI/UX Requirements

### 11.1 Design Principles
1. **Child-Friendly**: Large buttons, bright colors, clear icons
2. **Immediate Feedback**: Animations and sounds for every action
3. **Visual Progress**: Always show current state and next goal
4. **Minimal Text**: Use icons and visuals where possible
5. **Consistent**: Same patterns throughout the app

### 11.2 Color Palette

| Usage | Color | Hex Code |
|-------|-------|----------|
| Primary | Purple | #8B5CF6 |
| Secondary | Green | #10B981 |
| Accent | Yellow | #FBBF24 |
| Success | Emerald | #059669 |
| Warning | Orange | #F97316 |
| Error | Red | #EF4444 |
| Background (Light) | Off-White | #F8FAFC |
| Background (Dark) | Slate | #1E293B |
| Text | Dark Gray | #1F2937 |

### 11.3 Key Screens

#### 11.3.1 Child Interface
1. **Home/Room View**
   - Virtual room as main focus (70% of screen)
   - Cleanliness score indicator
   - Quick task counter
   - Points balance
   - Streak indicator

2. **Task List**
   - Card-based task display
   - Swipe to complete (optional)
   - Filter by zone
   - Points highlighted

3. **Rewards Store**
   - Category tabs (Themes, Furniture, Accessories)
   - Grid layout with previews
   - Point cost clearly shown
   - "Owned" badge for purchased

4. **Profile**
   - Avatar display
   - Level & XP bar
   - Achievements
   - Statistics

#### 11.3.2 Parent Interface
1. **Dashboard**
   - Child overview cards
   - Today's activity
   - Pending verifications
   - Quick actions

2. **Task Management**
   - Task list with filters
   - Create/Edit modal
   - Template browser
   - Recurring task setup

3. **Reports**
   - Weekly charts
   - Completion rates
   - Streak history
   - Export option

### 11.4 Animation Requirements

| Action | Animation | Duration |
|--------|-----------|----------|
| Task Complete | Checkmark burst + confetti | 1.5s |
| Point Award | Points flying to balance | 1s |
| Room Transform | Zone cleanup animation | 2s |
| Level Up | Celebration overlay | 3s |
| Navigation | Page slide | 0.3s |
| Loading | Skeleton shimmer | Until loaded |

---

## 12. Security Requirements

### 12.1 Authentication & Authorization
| Requirement | Implementation |
|-------------|----------------|
| Password Requirements | Min 8 chars, 1 uppercase, 1 number |
| Session Management | JWT with 24h expiry, refresh tokens |
| Child Protection | PIN-based login, no personal data exposed |
| Role-Based Access | Parent vs Child permissions enforced |

### 12.2 Data Protection
| Requirement | Implementation |
|-------------|----------------|
| Data Encryption | TLS 1.3 in transit, AES-256 at rest |
| PII Protection | Minimal collection, encrypted storage |
| COPPA Compliance | Parental consent, data minimization |
| Data Deletion | Right to delete, automated after inactivity |

### 12.3 API Security
| Requirement | Implementation |
|-------------|----------------|
| Rate Limiting | 100 requests/minute per user |
| Input Validation | Server-side validation on all inputs |
| CORS | Restricted to approved domains |
| SQL Injection | Parameterized queries (Supabase RLS) |

---

## 13. Implementation Phases

### Phase 1: MVP Foundation (Weeks 1-4)

#### Week 1-2: Setup & Core Infrastructure
- [ ] Project setup (Next.js, Supabase)
- [ ] Database schema implementation
- [ ] Authentication system (parent + child)
- [ ] Basic UI components library

#### Week 3-4: Core Features
- [ ] Virtual room component (static)
- [ ] Task management (CRUD)
- [ ] Points system
- [ ] Basic parent dashboard

### Phase 2: Room Experience (Weeks 5-8)

#### Week 5-6: Room Interactivity
- [ ] Room state management
- [ ] Zone-based cleanliness tracking
- [ ] Transformation animations
- [ ] Basic decorations

#### Week 7-8: Gamification
- [ ] Streak system
- [ ] Rewards store
- [ ] Level progression
- [ ] Celebration animations

### Phase 3: Polish & Enhancement (Weeks 9-12)

#### Week 9-10: Parent Features
- [ ] Task verification flow
- [ ] Progress reports
- [ ] Notification system
- [ ] Recurring tasks

#### Week 11-12: Testing & Launch
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Bug fixes
- [ ] Production deployment

---

## 14. Success Metrics

### 14.1 Key Performance Indicators (KPIs)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Daily Active Users (DAU) | 60% of registered | Analytics |
| Task Completion Rate | 70%+ | Database |
| Average Session Duration | 5+ minutes | Analytics |
| Week 1 Retention | 50%+ | Cohort analysis |
| Month 1 Retention | 25%+ | Cohort analysis |
| Average Streak Length | 5+ days | Database |

### 14.2 User Satisfaction
| Metric | Target | Measurement |
|--------|--------|-------------|
| App Store Rating | 4.5+ stars | Store reviews |
| NPS Score | 50+ | In-app survey |
| Support Tickets | < 5% of users | Support system |

---

## 15. Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Children lose interest | Medium | High | Varied rewards, surprise events, social features |
| Tech complexity of animations | Medium | Medium | Use Lottie for pre-made animations |
| Parental non-engagement | Medium | High | Minimal parent effort required, push notifications |
| Scope creep | High | Medium | Strict MVP definition, phased approach |
| Performance issues | Low | High | Performance testing, lazy loading |
| Competition | Medium | Low | Focus on unique room simulation aspect |

---

## 16. Future Scope (Post-MVP)

### Phase 4+ Features

#### 16.1 Advanced Features
- [ ] AI-powered photo verification of room cleanliness
- [ ] Voice assistant integration ("Hey Tidy, what's my room score?")
- [ ] AR preview of decorations in real room
- [ ] Smart home integration (lights + music when cleaning)

#### 16.2 Social Features
- [ ] Room showcase (public/friends)
- [ ] Friend system
- [ ] Weekly room competitions
- [ ] Sibling challenges

#### 16.3 Monetization (If Applicable)
- [ ] Premium themes
- [ ] Ad-free experience
- [ ] Family plan subscriptions

#### 16.4 Platform Expansion
- [ ] Native iOS app
- [ ] Native Android app
- [ ] Tablet-optimized experience
- [ ] Smart TV app for family viewing

---

## 📝 Appendix

### A. Glossary
| Term | Definition |
|------|------------|
| Zone | A section of the virtual room (Bed, Floor, Desk, Closet) |
| Cleanliness Score | Percentage (0-100%) indicating room tidiness |
| Streak | Consecutive days with at least one completed task |
| Decoration | Virtual item to customize the room |
| Theme | Complete room style package |

### B. References
- COPPA Guidelines: https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa
- Gamification Best Practices: Yu-kai Chou's Octalysis Framework
- Child UX Design: Nielsen Norman Group Guidelines

---

**Document Prepared By:** AI Assistant  
**Last Updated:** December 16, 2024  
**Next Review:** After Phase 1 Completion

---

*This PRD is a living document and will be updated as the project evolves.*
