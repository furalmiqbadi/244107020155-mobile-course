import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../widgets/note_tile.dart';

// halaman utama, tetap berfungsi penuh dalam mode pesawat.
// menampilkan badge jumlah catatan yang belum tersinkron (dirty).
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Cache posts (cache-first demo)',
            onPressed: () => context.push('/cache'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // bar status sync + toggle offline deterministik.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: dirtyAsync.when(
                    loading: () => const Text('Menghitung antrean sync...'),
                    error: (e, _) => Text('Gagal hitung dirty: $e'),
                    data: (count) => Text(
                      count == 0
                          ? 'Semua tersinkron ✓'
                          : '$count belum tersinkron',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () async {
                      final notifier = ref.read(notesProvider.notifier);
                      final synced = await notifier.sync();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              synced == 0
                                  ? 'Tidak ada yang perlu disinkron.'
                                  : '$synced catatan tersinkron.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Sync sekarang'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat catatan: $e',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(notesProvider),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan. Tambah satu!'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(notesProvider),
                  child: ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteTile(
                        note: note,
                        onTap: note.id == null
                            ? null
                            : () => context.push('/note/${note.id}'),
                        onDelete: note.id == null
                            ? null
                            : () => ref
                                  .read(notesProvider.notifier)
                                  .deleteNote(note.id!),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah catatan',
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
              autofocus: true,
            ),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Isi (opsional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              Navigator.pop(context);
              await ref
                  .read(notesProvider.notifier)
                  .addNote(title, bodyCtrl.text.trim());
            },
            child: const Text('Simpan (dirty=1)'),
          ),
        ],
      ),
    );
  }
}
