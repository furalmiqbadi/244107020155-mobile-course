import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// model satu item statistik
class StatItem {
  const StatItem({required this.label, required this.value});
  final String label;
  final int value;

  // biar gampang dibaca pas debugging
  @override
  String toString() => 'StatItem(label: $label, value: $value)';

  // isi sama dianggap sama
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatItem && label == other.label && value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

// notifier data statistik pura-pura dari server
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  // random bisa diganti pas testing
  final Random _random;

  StatsNotifier({Random? random}) : _random = random ?? Random();

  // jalan otomatis pas pertama dibaca
  @override
  Future<List<StatItem>> build() => _fetchStats();

  // pura-pura fetch, delay 2 detik dan kadang gagal
  Future<List<StatItem>> _fetchStats() async {
    // tunggu 2 detik kayak kena jaringan
    await Future.delayed(const Duration(seconds: 2));

    // 30 persen gagal
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik dari server');
    }

    // kalau sukses balik 3 item
    return const [
      StatItem(label: 'Pengguna Aktif', value: 1200),
      StatItem(label: 'Tugas Selesai', value: 340),
      StatItem(label: 'Tugas Tertunda', value: 85),
    ];
  }

  // coba lagi dari loading
  Future<void> retry() async {
    state = const AsyncLoading();
    // guard ubah exception jadi AsyncError
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

// daftarin providernya
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);
