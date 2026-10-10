import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _copyToken(
    BuildContext context,
    String? token,
    String label,
  ) async {
    if (token == null || token.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$label disalin.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenPreview = ref.watch(tokenPreviewProvider);
    final fullAuthToken = ref.watch(fullAuthTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Auth Token (ketuk untuk salin)'),
              subtitle: tokenPreview.when(
                loading: () => const Text('Memuat...'),
                error: (e, _) => Text('Gagal: $e'),
                data: (t) => Text(t),
              ),
              trailing: const Icon(Icons.copy_outlined),
              onTap: () =>
                  _copyToken(context, fullAuthToken.value, 'Auth token'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: FutureBuilder<String>(
              future: getFcmTokenPreview(),
              builder: (context, snapshot) {
                return ListTile(
                  leading: const Icon(Icons.token_outlined),
                  title: const Text('FCM Device Token (ketuk untuk salin)'),
                  subtitle: Text(
                    snapshot.connectionState == ConnectionState.waiting
                        ? 'Memuat token FCM...'
                        : (snapshot.data ?? 'Tidak tersedia'),
                  ),
                  trailing: const Icon(Icons.copy_outlined),
                  onTap: () async {
                    final full = await getFcmTokenFull();
                    if (context.mounted) {
                      await _copyToken(context, full, 'FCM token');
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.campaign_outlined),
                  title: const Text('Topik pengumuman-kampus'),
                  subtitle: const Text('Broadcast untuk semua mahasiswa.'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: subscribeCampusTopic,
                          child: const Text('Subscribe'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: unsubscribeCampusTopic,
                          child: const Text('Unsubscribe'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => context.push(AppRoutes.announcement('3')),
            child: const Text('Buka contoh /pengumuman/3'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: showTestLocalNotification,
            icon: const Icon(Icons.notifications_outlined),
            label: const Text('Test banner lokal (tanpa Firebase)'),
          ),
        ],
      ),
    );
  }
}
