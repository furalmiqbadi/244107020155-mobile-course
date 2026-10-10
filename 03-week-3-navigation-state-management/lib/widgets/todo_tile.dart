import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';

// widget pisah buat satu tugas biar build pendek
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
      // centang selesai atau belum
      leading: Checkbox(value: todo.done, onChanged: (_) => onToggle()),
      // judul dicoret kalau sudah selesai
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      // tombol hapus
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
