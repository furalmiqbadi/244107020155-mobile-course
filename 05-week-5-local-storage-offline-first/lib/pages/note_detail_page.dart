import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

// detail membaca dari repository lokal via noteDetailProvider,
// bukan dari state halaman list.
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(noteDetailProvider(noteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${note.id} • ${note.updatedAt.toLocal()} • '
                  '${note.dirty ? "belum tersinkron" : "tersinkron"}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const Divider(height: 32),
                Text(note.body.isEmpty ? '(kosong)' : note.body),
              ],
            ),
          );
        },
      ),
    );
  }
}
