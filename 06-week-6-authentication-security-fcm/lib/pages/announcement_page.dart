import 'package:flutter/material.dart';

// tujuan deep link dari klik notifikasi
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengumuman #$id',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Contoh isi: Kelas Mobile pindah ke Ruang A2 jam 13.00. '
              'Halaman ini dibuka via data.route dari FCM.',
            ),
          ],
        ),
      ),
    );
  }
}
