import 'package:flutter/material.dart';

import '../data/local/note.dart';

// baris catatan tersendiri dengan badge "belum tersinkron"
// bila note.dirty true (refactoring challenge no.1).
class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, this.onTap, this.onDelete});

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(note.id?.toString() ?? '?')),
      title: Text(
        note.title.isEmpty ? '(tanpa judul)' : note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.body.isNotEmpty)
            Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              if (note.dirty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'belum tersinkron',
                    style: TextStyle(fontSize: 11, color: Colors.brown),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'tersinkron',
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ),
            ],
          ),
        ],
      ),
      onTap: onTap,
      trailing: onDelete == null
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus',
              onPressed: onDelete,
            ),
    );
  }
}
