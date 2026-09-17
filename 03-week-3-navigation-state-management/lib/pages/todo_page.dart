import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

// halaman utama untuk menampilkan dan mengelola daftar tugas
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch digunakan di build agar UI otomatis ter-rebuild saat state berubah
    final todos = ref.watch(todoListProvider);
    // provider turunan untuk menampilkan jumlah tugas yang belum selesai
    final unfinishedTodos = ref.watch(unfinishedTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo (${unfinishedTodos.length} belum selesai)'),
      ),
      // menampilkan pesan kosong jika belum ada tugas, sebaliknya tampilkan list
      body: todos.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) => TodoTile(
                todo: todos[index],
                // ref.read digunakan di callback karena tidak perlu memicu rebuild
                onToggle: () =>
                    ref.read(todoListProvider.notifier).toggle(index),
                onDelete: () =>
                    ref.read(todoListProvider.notifier).remove(index),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      // navigation bar untuk berpindah antar halaman utama
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // context.go mengganti stack navigasi (cocok untuk tab utama)
          if (index == 0) context.go('/');
          if (index == 1) context.go('/stats');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.check_box), label: 'ToDo'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }

  // menampilkan dialog untuk menambahkan tugas baru ke dalam daftar
  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // menambahkan tugas baru melalui notifier lalu tutup dialog
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
