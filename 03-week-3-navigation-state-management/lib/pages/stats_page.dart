import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stats_provider.dart';

// halaman statistik yang menampilkan data dari server dengan penanganan state asinkron
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch memantau perubahan state asinkron dan memicu rebuild UI
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // menangani tiga kondisi state asinkron: loading, error, dan success
      body: statsAsync.when(
        // menampilkan indikator loading saat data sedang diambil
        loading: () => const Center(child: CircularProgressIndicator()),
        // menampilkan pesan error dan tombol retry saat terjadi kegagalan
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('$err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  // ref.read digunakan di callback untuk memanggil retry tanpa rebuild
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        // menampilkan daftar statistik saat data berhasil dimuat
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            final icons = [Icons.people, Icons.check_circle, Icons.pending];
            return ListTile(
              leading: Icon(
                index < icons.length ? icons[index] : Icons.bar_chart,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(item.label),
              subtitle: Text('Jumlah: ${item.value}'),
            );
          },
        ),
      ),
      // navigation bar untuk berpindah antar halaman utama
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
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
}
