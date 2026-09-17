import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

// unit test untuk StatsNotifier dengan strategi dependency injection pada random
void main() {
  // helper untuk membuat container dengan random yang bisa dikontrol
  ProviderContainer createContainer({required Random random}) {
    return ProviderContainer(
      overrides: [
        // override provider agar menggunakan random yang sudah di-seed
        statsProvider.overrideWith(() => StatsNotifier(random: random)),
      ],
    );
  }

  // test 1: skenario sukses di mana data statistik berhasil dimuat
  test('build() mengembalikan 3 item statistik saat berhasil', () async {
    // random yang selalu menghasilkan 0.5 (> 0.3 sehingga tidak gagal)
    final alwaysSucceed = _FixedRandom(0.5);
    final container = createContainer(random: alwaysSucceed);

    // subscribe ke provider untuk memicu build() di StatsNotifier
    final subscription = container.listen(statsProvider, (_, _) {});

    // tunggu hingga future selesai (delay 2 detik di provider)
    await Future.delayed(const Duration(seconds: 3));

    // ambil state terkini dari provider
    final state = container.read(statsProvider);

    // verifikasi state berisi data dengan jumlah item yang sesuai
    expect(state.hasValue, isTrue, reason: 'State harus berisi data');
    expect(state.value!.length, 3, reason: 'Harus ada tepat 3 item statistik');

    // verifikasi isi setiap item sesuai dengan yang diharapkan
    expect(
      state.value![0],
      const StatItem(label: 'Pengguna Aktif', value: 1200),
    );
    expect(state.value![1], const StatItem(label: 'Tugas Selesai', value: 340));
    expect(state.value![2], const StatItem(label: 'Tugas Tertunda', value: 85));

    // bersihkan resource setelah test selesai
    subscription.close();
    container.dispose();
  });

  // test 2: skenario gagal di mana exception dilempar saat fetch
  test('build() melempar exception saat simulasi gagal (< 0.3)', () async {
    // random yang selalu menghasilkan 0.1 (< 0.3 sehingga selalu gagal)
    final alwaysFail = _FixedRandom(0.1);
    final container = createContainer(random: alwaysFail);

    final subscription = container.listen(statsProvider, (_, _) {});

    // tunggu hingga future selesai
    await Future.delayed(const Duration(seconds: 3));

    final state = container.read(statsProvider);

    // verifikasi state berisi error dengan pesan yang sesuai
    expect(state.hasError, isTrue, reason: 'State harus berisi error');
    expect(
      state.error.toString(),
      contains('Gagal mengambil data statistik'),
      reason: 'Pesan error harus sesuai',
    );

    subscription.close();
    container.dispose();
  });

  // test 3: skenario retry setelah error berhasil mengambil data
  test('retry() berhasil setelah error sebelumnya', () async {
    // urutan: pertama gagal (0.1), lalu berhasil (0.5)
    final sequentialRandom = _SequentialRandom([0.1, 0.5]);
    final container = createContainer(random: sequentialRandom);

    final subscription = container.listen(statsProvider, (_, _) {});

    // tunggu build() pertama selesai yang akan gagal karena 0.1 < 0.3
    await Future.delayed(const Duration(seconds: 3));

    var state = container.read(statsProvider);
    expect(state.hasError, isTrue, reason: 'Build pertama harus gagal');

    // panggil retry() yang kali ini akan sukses karena random menghasilkan 0.5
    await container.read(statsProvider.notifier).retry();

    state = container.read(statsProvider);
    expect(state.hasValue, isTrue, reason: 'Retry harus berhasil');
    expect(state.value!.length, 3);

    subscription.close();
    container.dispose();
  });

  // test 4: memverifikasi equality dan toString pada model StatItem
  test('StatItem equality bekerja berdasarkan isi, bukan referensi', () {
    const a = StatItem(label: 'Test', value: 42);
    const b = StatItem(label: 'Test', value: 42);
    const c = StatItem(label: 'Lain', value: 99);

    // dua objek dengan label dan value sama harus dianggap equal
    expect(a, equals(b));
    // dua objek dengan isi berbeda harus tidak equal
    expect(a, isNot(equals(c)));
    // toString harus mengandung label dan value untuk debugging
    expect(a.toString(), contains('Test'));
    expect(a.toString(), contains('42'));
  });
}

// helper class untuk random yang selalu mengembalikan nilai tetap
class _FixedRandom implements Random {
  final double _value;
  _FixedRandom(this._value);

  @override
  double nextDouble() => _value;

  // method lain tidak digunakan tetapi harus diimplementasi karena interface Random
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

// helper class untuk random yang mengembalikan nilai secara berurutan
class _SequentialRandom implements Random {
  final List<double> _values;
  int _index = 0;

  _SequentialRandom(this._values);

  @override
  double nextDouble() {
    // ambil nilai saat ini, lalu geser ke index berikutnya
    final value = _values[_index];
    if (_index < _values.length - 1) _index++;
    return value;
  }

  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}
