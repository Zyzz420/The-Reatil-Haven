import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/views/dashboard_home_screen.dart';
import '../features/priority/views/priority_screen.dart';
import '../features/projects/views/project_details_screen.dart';
import '../features/search/views/search_screen.dart';
import '../features/settings/views/settings_screen.dart';
import '../features/shell/dashboard_shell.dart';
import '../features/teams/views/teams_screen.dart';
import '../features/timeline/views/timeline_screen.dart';
import '../features/users/views/users_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    routes: [
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardHomeScreen()),
          ),
          GoRoute(
            path: '/timeline',
            name: 'timeline',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TimelineScreen()),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UsersScreen()),
          ),
          GoRoute(
            path: '/teams',
            name: 'teams',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TeamsScreen()),
          ),
          GoRoute(
            path: '/projects/:id',
            name: 'project-details',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProjectDetailsScreen(
                projectId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: '/priority/:priority',
            name: 'priority',
            pageBuilder: (context, state) => NoTransitionPage(
              child: PriorityScreen(
                priority: state.pathParameters['priority']!,
              ),
            ),
          ),
        ],
      ),
    ],
  );
});
