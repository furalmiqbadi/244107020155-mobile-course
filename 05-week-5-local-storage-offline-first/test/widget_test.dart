import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

void main() {
  testWidgets('NoteTile menampilkan badge belum tersinkron bila dirty',
      (WidgetTester tester) async {
    final note = Note(
      id: 1,
      title: 'Belanja',
      body: 'Susu + roti',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NoteTile(note: note))),
    );
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('belum tersinkron'), findsOneWidget);
  });

  testWidgets('NoteTile menampilkan tersinkron bila bersih',
      (WidgetTester tester) async {
    final note = Note(
      id: 2,
      title: 'Baca',
      updatedAt: DateTime(2026, 9, 18),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NoteTile(note: note))),
    );
    expect(find.text('tersinkron'), findsOneWidget);
  });
}
