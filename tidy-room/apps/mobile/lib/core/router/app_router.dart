import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/child_login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/room/screens/room_screen.dart';
import '../../features/tasks/screens/task_list_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/store/screens/store_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/parent/screens/parent_dashboard_screen.dart';
import '../../features/parent/screens/manage_children_screen.dart';
import '../../features/parent/screens/assign_task_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/child-login',
        name: 'childLogin',
        builder: (context, state) => const ChildLoginScreen(),
      ),

      // Child Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/room',
            name: 'room',
            builder: (context, state) => const RoomScreen(),
          ),
          GoRoute(
            path: '/tasks',
            name: 'tasks',
            builder: (context, state) => const TaskListScreen(),
            routes: [
              GoRoute(
                path: ':taskId',
                name: 'taskDetail',
                builder: (context, state) {
                  final taskId = state.pathParameters['taskId']!;
                  return TaskDetailScreen(taskId: taskId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/store',
            name: 'store',
            builder: (context, state) => const StoreScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Parent Routes
      GoRoute(
        path: '/parent',
        name: 'parentDashboard',
        builder: (context, state) => const ParentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'children',
            name: 'manageChildren',
            builder: (context, state) => const ManageChildrenScreen(),
          ),
          GoRoute(
            path: 'assign-task',
            name: 'assignTask',
            builder: (context, state) => const AssignTaskScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
