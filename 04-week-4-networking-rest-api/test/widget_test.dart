import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/widgets/post_tile.dart';

void main() {
  testWidgets('PostTile renders post details correctly', (WidgetTester tester) async {
    const post = Post(
      userId: 1,
      id: 99,
      title: 'Judul Post Uji',
      body: 'Isi ringkasan komentar dan postingan.',
    );

    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostTile(
            post: post,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('99'), findsOneWidget);
    expect(find.text('Judul Post Uji'), findsOneWidget);
    expect(find.text('Isi ringkasan komentar dan postingan.'), findsOneWidget);

    await tester.tap(find.byType(PostTile));
    expect(tapped, isTrue);
  });
}
