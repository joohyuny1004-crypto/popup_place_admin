import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/theme/admin_theme.dart';
import 'features/bookings/bookings_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/notices/notices_page.dart';
import 'features/spaces/spaces_page.dart';
import 'features/statistics/statistics_page.dart';
import 'features/support/support_page.dart';
import 'features/users/users_page.dart';
import 'shared/widgets/admin_shell.dart';

void main() {
  runApp(const AdminApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AdminShell(
        child: child,
        currentPath: state.matchedLocation,
      ),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/users', builder: (_, __) => const UsersPage()),
        GoRoute(path: '/spaces', builder: (_, __) => const SpacesPage()),
        GoRoute(path: '/bookings', builder: (_, __) => const BookingsPage()),
        GoRoute(path: '/support', builder: (_, __) => const SupportPage()),
        GoRoute(path: '/notices', builder: (_, __) => const NoticesPage()),
        GoRoute(path: '/statistics', builder: (_, __) => const StatisticsPage()),
      ],
    ),
  ],
);

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '팝업플레이스 관리자',
      theme: AdminTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
