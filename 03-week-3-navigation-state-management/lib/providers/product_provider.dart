import 'package:flutter_riverpod/flutter_riverpod.dart';

// notifier asinkron untuk mengelola state produk dengan simulasi error
class ProductsNotifier extends AsyncNotifier<List<String>> {
  // dipanggil otomatis saat provider pertama kali dibaca
  @override
  Future<List<String>> build() async {
    // lempar exception untuk simulasi server mati atau tidak dapat diakses
    throw Exception('Gagal terhubung ke server');
  }

  // mereset state ke loading dan mencoba fetch ulang secara aman
  Future<void> refresh() async {
    state = const AsyncLoading();
    // guard menangkap exception dan mengubahnya menjadi AsyncError
    state = await AsyncValue.guard(() => _fetch());
  }

  // simulasi fetch data dengan delay 1 detik dan mengembalikan daftar produk
  Future<List<String>> _fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    return ['Keyboard', 'Mouse', 'Monitor', 'Headset'];
  }
}

// mendaftarkan notifier sebagai provider global agar dapat dipantau oleh UI
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<String>>(
  ProductsNotifier.new,
);
