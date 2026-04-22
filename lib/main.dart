import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/theme/admin_theme.dart';
import 'data/auth_repository.dart';
import 'data/supabase_config.dart';
import 'features/auth/login_page.dart';
import 'features/bookings/bookings_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/notices/notices_page.dart';
import 'features/spaces/spaces_page.dart';
import 'features/statistics/statistics_page.dart';
import 'features/support/support_page.dart';
import 'features/users/users_page.dart';
import 'shared/widgets/admin_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
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

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final _repo = AdminAuthRepository();
  bool _loading = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _check();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        setState(() => _authed = false);
      }
    });
  }

  Future<void> _check() async {
    final ok = await _repo.isCurrentAdmin();
    if (!mounted) return;
    setState(() {
      _authed = ok;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        theme: AdminTheme.light,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (!_authed) {
      return MaterialApp(
        title: '팝업플레이스 관리자',
        theme: AdminTheme.light,
        debugShowCheckedModeBanner: false,
        home: LoginPage(onLoggedIn: () => setState(() => _authed = true)),
      );
    }
    return MaterialApp.router(
      title: '팝업플레이스 관리자',
      theme: AdminTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
