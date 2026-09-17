import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/todo_page.dart';
import 'pages/stats_page.dart';

// entry point aplikasi, ProviderScope digunakan agar state Riverpod dapat diakses secara global
void main() => runApp(const ProviderScope(child: MyApp()));

// konfigurasi rute aplikasi menggunakan GoRouter dengan halaman awal di root
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // daftar rute yang memetakan URL ke halaman masing-masing
    GoRoute(path: '/', builder: (context, state) => const TodoPage()),
    GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
  ],
);

// root widget yang menggabungkan konfigurasi router dan tema aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // penggunaan MaterialApp.router agar aplikasi dapat membaca rute dari GoRouter
    return MaterialApp.router(
      title: 'Week 3 - ToDo & Stats',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routerConfig: _router,
    );
  }
}
