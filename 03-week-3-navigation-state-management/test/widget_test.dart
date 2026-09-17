import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/main.dart';

void main() {
  // mensimulasikan interaksi user menambahkan tugas baru melalui UI
  testWidgets('menambah tugas baru lewat ui', (tester) async {
    // merender aplikasi dan menunggu sampai semua widget stabil
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // memverifikasi pesan kosong muncul saat belum ada tugas
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // menekan tombol add untuk membuka dialog input tugas
    await tester.tap(find.byIcon(Icons.add));

    // menunggu dialog muncul dengan beberapa pump eksplisit
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // memastikan dialog sudah muncul sebelum melanjutkan ke langkah berikutnya
    expect(find.byType(AlertDialog), findsOneWidget);

    // memasukkan teks tugas baru ke dalam TextField
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.pump();

    // menekan tombol tambah untuk menyimpan tugas ke dalam daftar
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // memverifikasi tugas baru berhasil muncul di dalam daftar
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
