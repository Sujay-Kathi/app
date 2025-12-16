# 🏠 Tidy Room Simulator

**Make Cleaning Fun for Kids!**

A gamified app that transforms boring chores into an exciting adventure. Children complete real-world cleaning tasks to transform their virtual room, earn points, and unlock rewards!

## 📁 Project Structure

```
tidy-room/
├── apps/
│   ├── mobile/          # Flutter app (iOS & Android)
│   └── web/             # Next.js web app
├── packages/
│   └── shared/          # Shared types and utilities
├── SUPABASE_SETUP.sql   # Database schema and setup
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+ (for web app)
- **Flutter** 3.16+ (for mobile app)
- **Supabase** account (for backend)

### 1. Set Up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to SQL Editor and run the `SUPABASE_SETUP.sql` script
3. Create a storage bucket named `tidy-room-assets`
4. Copy your project URL and anon key

### 2. Run the Web App

```bash
cd apps/web

# Install dependencies
npm install

# Create environment file
cp env.example .env.local
# Edit .env.local with your Supabase credentials

# Run development server
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

### 3. Run the Mobile App

```bash
cd apps/mobile

# Get dependencies
flutter pub get

# Update Supabase credentials in lib/main.dart

# Run on device/emulator
flutter run
```

## ✨ Features

### For Kids 👶
- **Virtual Room** - Watch your room transform as you clean
- **Tasks** - Complete daily & weekly cleaning tasks
- **Points & Levels** - Earn points and level up
- **Streaks** - Maintain daily streaks for bonus multipliers
- **Rewards Store** - Buy themes, decorations, and virtual pets
- **Achievements** - Unlock badges for milestones

### For Parents 👨‍👩‍👧
- **Dashboard** - Monitor all children's progress
- **Task Management** - Assign tasks with custom points
- **Verification** - Approve tasks requiring photo proof
- **Reports** - View activity and progress reports
- **Family Management** - Add children with PIN codes

## 🎨 Zone System

The virtual room is divided into 5 zones:

| Zone | Color | Tasks |
|------|-------|-------|
| 🛏️ Bed | Pink | Make bed, arrange pillows |
| 🧹 Floor | Blue | Pick up toys, vacuum |
| 📚 Desk | Yellow | Organize, clear clutter |
| 👕 Closet | Green | Hang clothes, organize |
| ✨ General | Purple | Dust, trash, general tidy |

## 🔧 Tech Stack

### Web App
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **State**: Zustand
- **Backend**: Supabase

### Mobile App
- **Framework**: Flutter 3.16+
- **State**: Provider
- **Routing**: go_router
- **Animations**: flutter_animate
- **Backend**: supabase_flutter

### Backend
- **Database**: PostgreSQL (Supabase)
- **Auth**: Supabase Auth
- **Storage**: Supabase Storage
- **Realtime**: Supabase Realtime

## 📱 Screenshots

*Coming soon...*

## 🗄️ Database Schema

Key tables:
- `tidy_families` - Family accounts
- `tidy_profiles` - User profiles (parents)
- `tidy_children` - Child profiles with points/levels
- `tidy_rooms` - Virtual room state
- `tidy_tasks` - Assigned/completed tasks
- `tidy_themes` - Room themes
- `tidy_decorations` - Purchasable items
- `tidy_streaks` - Daily streak tracking
- `tidy_achievements` - Badge definitions

## 🔐 Security

- Parent email/password authentication
- Child PIN-based login
- Row Level Security (RLS) policies
- Encrypted data at rest
- COPPA compliance ready

## 📝 License

MIT License - See LICENSE file

## 🙏 Contributing

Contributions welcome! Please read our contributing guidelines.

---

**Made with ❤️ for families**
