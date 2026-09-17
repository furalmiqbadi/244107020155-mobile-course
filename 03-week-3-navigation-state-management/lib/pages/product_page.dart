import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

// halaman produk yang menggunakan ConsumerWidget untuk membaca provider asinkron
class ProductPage extends ConsumerWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch memantau perubahan state asinkron dan memicu rebuild UI
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      // menangani tiga kondisi state asinkron menggunakan pola when
      body: productsAsync.when(
        // menampilkan indikator loading saat data sedang diambil dari server
        loading: () => const Center(child: CircularProgressIndicator()),
        // menampilkan pesan error dan tombol retry saat terjadi kegagalan
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $err'),
              FilledButton(
                // ref.invalidate mereset provider dan menjalankan ulang build()
                onPressed: () => ref.invalidate(productsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // menampilkan daftar produk saat data berhasil dimuat
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) =>
              ListTile(title: Text(products[index])),
        ),
      ),
    );
  }
}
