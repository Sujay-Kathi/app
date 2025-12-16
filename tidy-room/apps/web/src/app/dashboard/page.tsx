'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import {
    Home,
    Users,
    CheckCircle2,
    Clock,
    Flame,
    Star,
    Trophy,
    Plus,
    Settings,
    LogOut,
    Bell,
    ChevronRight
} from 'lucide-react';

// Helper function to format numbers consistently (avoids hydration mismatch)
function formatNumber(num: number): string {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

export default function DashboardPage() {
    const [activeTab, setActiveTab] = useState('overview');

    // Demo data
    const children = [
        {
            id: '1',
            name: 'Arjun',
            emoji: '👦',
            age: 8,
            streak: 7,
            roomScore: 72,
            level: 10,
            pendingTasks: 2,
            completedToday: 1,
            totalPoints: 1250
        },
        {
            id: '2',
            name: 'Priya',
            emoji: '👧',
            age: 11,
            streak: 12,
            roomScore: 85,
            level: 12,
            pendingTasks: 1,
            completedToday: 2,
            totalPoints: 2100
        },
    ];

    const recentActivity = [
        { id: '1', emoji: '✅', text: 'Arjun completed "Make the Bed"', time: '10 min ago', points: 15 },
        { id: '2', emoji: '🎉', text: 'Priya reached Level 12!', time: '1 hour ago' },
        { id: '3', emoji: '🔥', text: 'Arjun has a 7-day streak!', time: '2 hours ago' },
        { id: '4', emoji: '📝', text: 'New task assigned to Priya', time: '3 hours ago' },
    ];

    const pendingApprovals = [
        { id: '1', child: 'Arjun', task: 'Vacuum the Floor', emoji: '🧹', points: 50 },
        { id: '2', child: 'Priya', task: 'Organize Closet', emoji: '👕', points: 60 },
    ];

    return (
        <div className="min-h-screen bg-gray-50">
            {/* Sidebar */}
            <aside className="fixed left-0 top-0 h-full w-64 bg-white shadow-lg border-r border-gray-100 z-50">
                <div className="p-6">
                    {/* Logo */}
                    <Link href="/" className="flex items-center gap-3 mb-8">
                        <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
                            <Home className="w-5 h-5 text-white" />
                        </div>
                        <span className="text-xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                            Tidy Room
                        </span>
                    </Link>

                    {/* Navigation */}
                    <nav className="space-y-2">
                        <NavItem icon={Home} label="Overview" active={activeTab === 'overview'} onClick={() => setActiveTab('overview')} />
                        <NavItem icon={Users} label="Children" active={activeTab === 'children'} onClick={() => setActiveTab('children')} />
                        <NavItem icon={CheckCircle2} label="Tasks" active={activeTab === 'tasks'} onClick={() => setActiveTab('tasks')} />
                        <NavItem icon={Clock} label="Approvals" active={activeTab === 'approvals'} onClick={() => setActiveTab('approvals')} badge={2} />
                        <NavItem icon={Trophy} label="Achievements" active={activeTab === 'achievements'} onClick={() => setActiveTab('achievements')} />
                        <NavItem icon={Settings} label="Settings" active={activeTab === 'settings'} onClick={() => setActiveTab('settings')} />
                    </nav>
                </div>

                {/* User Profile */}
                <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-100">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
                            <span className="text-lg">👨</span>
                        </div>
                        <div className="flex-1">
                            <p className="font-medium text-sm">Parent Account</p>
                            <p className="text-xs text-gray-500">Kumar Family</p>
                        </div>
                        <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors">
                            <LogOut className="w-4 h-4 text-gray-400" />
                        </button>
                    </div>
                </div>
            </aside>

            {/* Main Content */}
            <main className="ml-64 p-8">
                {/* Header */}
                <div className="flex items-center justify-between mb-8">
                    <div>
                        <h1 className="text-2xl font-bold text-gray-900">Welcome back! 👋</h1>
                        <p className="text-gray-500">Here's what's happening with your family today.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <button className="relative p-2 hover:bg-gray-100 rounded-xl transition-colors">
                            <Bell className="w-5 h-5 text-gray-600" />
                            <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
                        </button>
                        <button className="flex items-center gap-2 bg-purple-600 text-white px-4 py-2 rounded-xl hover:bg-purple-700 transition-colors">
                            <Plus className="w-4 h-4" />
                            Assign Task
                        </button>
                    </div>
                </div>

                {/* Quick Stats */}
                <div className="grid grid-cols-4 gap-6 mb-8">
                    <StatCard
                        title="Total Children"
                        value="2"
                        icon={Users}
                        color="purple"
                        subtitle="Active accounts"
                    />
                    <StatCard
                        title="Tasks Today"
                        value="8"
                        icon={CheckCircle2}
                        color="green"
                        subtitle="3 completed"
                    />
                    <StatCard
                        title="Pending Approval"
                        value="2"
                        icon={Clock}
                        color="orange"
                        subtitle="Need review"
                    />
                    <StatCard
                        title="Active Streaks"
                        value="2"
                        icon={Flame}
                        color="red"
                        subtitle="🔥 Keep it up!"
                    />
                </div>

                {/* Children Overview */}
                <div className="grid grid-cols-2 gap-6 mb-8">
                    {children.map((child, index) => (
                        <motion.div
                            key={child.id}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: index * 0.1 }}
                            className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition-shadow"
                        >
                            <div className="flex items-start justify-between mb-4">
                                <div className="flex items-center gap-4">
                                    <div className="w-14 h-14 bg-gradient-to-br from-purple-100 to-pink-100 rounded-2xl flex items-center justify-center">
                                        <span className="text-3xl">{child.emoji}</span>
                                    </div>
                                    <div>
                                        <h3 className="font-bold text-lg">{child.name}</h3>
                                        <p className="text-sm text-gray-500">Level {child.level} • Age {child.age}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2 bg-orange-100 px-3 py-1.5 rounded-full">
                                    <Flame className="w-4 h-4 text-orange-500" />
                                    <span className="font-bold text-orange-600">{child.streak}</span>
                                </div>
                            </div>

                            {/* Room Progress */}
                            <div className="mb-4">
                                <div className="flex justify-between text-sm mb-2">
                                    <span className="text-gray-600">Room Cleanliness</span>
                                    <span className="font-semibold">{child.roomScore}%</span>
                                </div>
                                <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                                    <div
                                        className="h-full bg-gradient-to-r from-purple-500 to-pink-500 rounded-full transition-all duration-500"
                                        style={{ width: `${child.roomScore}%` }}
                                    />
                                </div>
                            </div>

                            {/* Stats Row */}
                            <div className="flex items-center justify-between text-sm">
                                <div className="flex items-center gap-4">
                                    <span className="flex items-center gap-1 text-orange-600">
                                        <Clock className="w-4 h-4" />
                                        {child.pendingTasks} pending
                                    </span>
                                    <span className="flex items-center gap-1 text-green-600">
                                        <CheckCircle2 className="w-4 h-4" />
                                        {child.completedToday} done
                                    </span>
                                </div>
                                <div className="flex items-center gap-1 text-amber-600">
                                    <Star className="w-4 h-4 fill-amber-400" />
                                    <span className="font-semibold">{formatNumber(child.totalPoints)}</span>
                                </div>
                            </div>
                        </motion.div>
                    ))}
                </div>

                {/* Bottom Section */}
                <div className="grid grid-cols-2 gap-6">
                    {/* Recent Activity */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="font-bold text-lg">Recent Activity</h3>
                            <button className="text-sm text-purple-600 hover:text-purple-700">View All</button>
                        </div>
                        <div className="space-y-3">
                            {recentActivity.map((activity, index) => (
                                <motion.div
                                    key={activity.id}
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    transition={{ delay: index * 0.05 }}
                                    className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl"
                                >
                                    <span className="text-xl">{activity.emoji}</span>
                                    <div className="flex-1">
                                        <p className="text-sm font-medium">{activity.text}</p>
                                        <p className="text-xs text-gray-500">{activity.time}</p>
                                    </div>
                                    {activity.points && (
                                        <span className="text-sm font-bold text-amber-600">+{activity.points}</span>
                                    )}
                                </motion.div>
                            ))}
                        </div>
                    </div>

                    {/* Pending Approvals */}
                    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="font-bold text-lg">Pending Approvals</h3>
                            <span className="bg-orange-100 text-orange-600 px-2 py-1 rounded-full text-xs font-semibold">
                                {pendingApprovals.length} waiting
                            </span>
                        </div>
                        <div className="space-y-3">
                            {pendingApprovals.map((approval, index) => (
                                <motion.div
                                    key={approval.id}
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    transition={{ delay: index * 0.05 }}
                                    className="flex items-center justify-between p-4 bg-gray-50 rounded-xl"
                                >
                                    <div className="flex items-center gap-3">
                                        <span className="text-2xl">{approval.emoji}</span>
                                        <div>
                                            <p className="font-medium">{approval.task}</p>
                                            <p className="text-sm text-gray-500">by {approval.child}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <button className="px-3 py-1.5 bg-green-100 text-green-600 rounded-lg text-sm font-medium hover:bg-green-200 transition-colors">
                                            Approve
                                        </button>
                                        <button className="px-3 py-1.5 bg-red-100 text-red-600 rounded-lg text-sm font-medium hover:bg-red-200 transition-colors">
                                            Reject
                                        </button>
                                    </div>
                                </motion.div>
                            ))}
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}

function NavItem({
    icon: Icon,
    label,
    active,
    onClick,
    badge
}: {
    icon: any;
    label: string;
    active: boolean;
    onClick: () => void;
    badge?: number;
}) {
    return (
        <button
            onClick={onClick}
            className={`w-full flex items-center justify-between px-4 py-3 rounded-xl transition-all ${active
                ? 'bg-purple-100 text-purple-700'
                : 'text-gray-600 hover:bg-gray-100'
                }`}
        >
            <div className="flex items-center gap-3">
                <Icon className="w-5 h-5" />
                <span className="font-medium">{label}</span>
            </div>
            {badge && (
                <span className="bg-orange-500 text-white text-xs px-2 py-0.5 rounded-full">
                    {badge}
                </span>
            )}
        </button>
    );
}

function StatCard({
    title,
    value,
    icon: Icon,
    color,
    subtitle
}: {
    title: string;
    value: string;
    icon: any;
    color: string;
    subtitle: string;
}) {
    const colorClasses: Record<string, string> = {
        purple: 'from-purple-500 to-purple-600',
        green: 'from-green-500 to-green-600',
        orange: 'from-orange-500 to-orange-600',
        red: 'from-red-500 to-red-600',
    };

    return (
        <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6"
        >
            <div className="flex items-center justify-between mb-3">
                <div className={`w-10 h-10 rounded-xl bg-gradient-to-br ${colorClasses[color]} flex items-center justify-center`}>
                    <Icon className="w-5 h-5 text-white" />
                </div>
                <span className="text-3xl font-bold">{value}</span>
            </div>
            <h3 className="font-medium text-gray-900">{title}</h3>
            <p className="text-sm text-gray-500">{subtitle}</p>
        </motion.div>
    );
}
