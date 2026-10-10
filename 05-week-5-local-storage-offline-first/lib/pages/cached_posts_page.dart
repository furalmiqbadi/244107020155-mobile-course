import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

// demo cache-first, tampilkan cache lokal seketika,
// refresh dari jaringan di background dan simpan hasilnya.
class CachedPostsPage extends ConsumerWidget {
  const CachedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(cachedPostsProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(cachedPostsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    forceOffline
                        ? 'Mode force-offline: hanya cache lokal.'
                        : 'Cache-first: lokal dulu, refresh background.',
                  ),
                ),
                const Text('Force offline'),
                Switch(
                  value: forceOffline,
                  onChanged: (v) =>
                      ref.read(forceOfflineProvider.notifier).set(v),
                ),
              ],
            ),
          ),
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal: $e')),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'Cache kosong. Matikan force-offline lalu refresh.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(post.id.toString())),
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
