import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// model data untuk merepresentasikan satu item statistik
class StatItem {
  const StatItem({required this.label, required this.value});
  final String label;
  final int value;

  // override toString agar output mudah dibaca saat debugging atau testing
  @override
  String toString() => 'StatItem(label: $label, value: $value)';

  // override equality agar dua objek dengan isi yang sama dianggap sama
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatItem && label == other.label && value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

// kelas notifier untuk mengelola state asinkron dari data statistik
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  // instance random yang bisa di-override untuk keperluan unit testing
  final Random _random;

  StatsNotifier({Random? random}) : _random = random ?? Random();

  // dipanggil otomatis saat provider pertama kali dibaca atau di-invalidate
  @override
  Future<List<StatItem>> build() => _fetchStats();

  // simulasi pengambilan data dari server dengan delay dan kemungkinan error
  Future<List<StatItem>> _fetchStats() async {
    // simulasi waktu tunggu jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // simulasi kegagalan server dengan probabilitas 30%
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik dari server');
    }

    // data statistik yang dikembalikan saat proses berhasil
    return const [
      StatItem(label: 'Pengguna Aktif', value: 1200),
      StatItem(label: 'Tugas Selesai', value: 340),
      StatItem(label: 'Tugas Tertunda', value: 85),
    ];
  }

  // mereset state ke loading dan mencoba fetch ulang secara aman
  Future<void> retry() async {
    state = const AsyncLoading();
    // guard menangkap exception dan mengubahnya menjadi AsyncError
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

// mendaftarkan notifier sebagai provider global untuk diakses oleh UI
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);
