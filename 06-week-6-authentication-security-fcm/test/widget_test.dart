import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/pages/announcement_page.dart';

// tanpa firebase sungguhan, yang diuji halaman tujuan deep link
void main() {
  testWidgets('AnnouncementPage tampilkan id dari route notifikasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AnnouncementPage(id: '3')));
    expect(find.text('Pengumuman #3'), findsOneWidget);
    expect(find.textContaining('data.route'), findsOneWidget);
  });
}
