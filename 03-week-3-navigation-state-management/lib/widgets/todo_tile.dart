import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';

// widget terpisah untuk menampilkan satu item tugas agar lebih modular
class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // checkbox untuk mengubah status tugas (selesai/belum)
      leading: Checkbox(value: todo.done, onChanged: (_) => onToggle()),
      // teks judul dengan coretan jika tugas sudah selesai
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      // tombol hapus untuk menghapus tugas dari daftar
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
