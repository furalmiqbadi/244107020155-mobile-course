import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stats_provider.dart';

// halaman statistik 3 state
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // loading, error, dan sukses
      body: statsAsync.when(
        // lagi loading
        loading: () => const Center(child: CircularProgressIndicator()),
        // error dan tombol coba lagi
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
                  // ref.read di callback biar nggak rebuild
                  onPressed: () => ref.read(statsProvider.notifier).retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        // sukses 3 item
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
      // navbar pindah tab utama
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          // go ganti stack, cocok buat tab
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
