import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

// halaman detail satu post, datanya dari list yang sudah dimuat
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: postsAsync.when(
        // lagi loading
        loading: () => const Center(child: CircularProgressIndicator()),
        // kalau error
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
        data: (posts) {
          // cari postnya dari list
          final Post? post = posts.where((p) => p.id == postId).firstOrNull;

          // kalau nggak ketemu
          if (post == null) {
            return const Center(child: Text('Post tidak ditemukan.'));
          }

          // content detail
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // lingkaran nomor id
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    post.id.toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 16),
                // judul gede tebal
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // info user
                Text(
                  'User ID: ${post.userId}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                // isi body lengkap
                Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}
