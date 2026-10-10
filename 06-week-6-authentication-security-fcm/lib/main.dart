import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

// firebase boleh nggak ada buat praktikum mock-auth
// tanpa google-services.json, init dilewati dan aplikasi tetap jalan
Future<bool> _tryInitFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerBackgroundHandler();
  final firebaseReady = await _tryInitFirebase();

  runApp(ProviderScope(child: MyApp(firebaseReady: firebaseReady)));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: AppRoutes.home,
      redirect: (context, state) {
        final loggedIn = ref.read(authStateProvider).value ?? false;
        final goingLogin = state.matchedLocation == AppRoutes.login;
        if (!loggedIn && !goingLogin) return AppRoutes.login;
        if (loggedIn && goingLogin) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        GoRoute(
          path: AppRoutes.announcementPattern,
          builder: (_, s) => AnnouncementPage(id: s.pathParameters['id'] ?? ''),
        ),
      ],
    );

    if (widget.firebaseReady) {
      _wireFcm();
    }
  }

  Future<void> _wireFcm() async {
    void go(String route) => _router.go(route);
    try {
      await requestNotificationPermission();
      await initLocalNotifications();
      onNotificationTap = go;
      await initFcmToken(
        onToken: (token) async {
          debugPrint(
            'FCM token updated: ${token.length > 12 ? '${token.substring(0, 12)}...' : token}',
          );
        },
      );
      listenForeground(go);
      await handleTerminated(go);
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: _router,
    );
  }
}
