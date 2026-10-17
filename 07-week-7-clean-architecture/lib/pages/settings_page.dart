import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

// pengaturan, toggle tema + waktu terakhir dibuka via SharedPreferences.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          darkAsync.when(
            loading: () => const ListTile(
              title: Text('Tema gelap'),
              trailing: CircularProgressIndicator(),
            ),
            error: (e, _) => ListTile(
              title: const Text('Tema gelap'),
              subtitle: Text('Gagal memuat: $e'),
            ),
            data: (isDark) => SwitchListTile(
              title: const Text('Tema gelap'),
              subtitle: const Text('Disimpan di SharedPreferences'),
              value: isDark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          const Divider(),
          lastOpenedAsync.when(
            loading: () => const ListTile(
              title: Text('Terakhir dibuka'),
              subtitle: Text('Memuat...'),
            ),
            error: (e, _) => ListTile(
              title: const Text('Terakhir dibuka'),
              subtitle: Text('Gagal memuat: $e'),
            ),
            data: (value) => ListTile(
              title: const Text('Terakhir dibuka'),
              subtitle: Text(value ?? 'Belum pernah dicatat'),
            ),
          ),
        ],
      ),
    );
  }
}
