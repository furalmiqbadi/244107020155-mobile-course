import 'dart:convert';

import 'package:dio/dio.dart';

import 'repositories/note_repository.dart';

// aturan konflik, last-write-wins berdasarkan updated_at.
// tanpa aturan eksplisit, sync dua arah akan menimpa data diam-diam.
// file ini menampung logika sync dan cache agar repository tetap fokus CRUD
// (refactoring challenge no.2).

// model ringan untuk cache bacaan (hasil GET /posts Minggu 4).
class CachedPost {
  const CachedPost({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  factory CachedPost.fromJson(Map<String, dynamic> json) => CachedPost(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );
}

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

// baca cache posts dari tabel cached_posts (cache-first, tampil seketika).
Future<List<CachedPost>> readCachedPosts(NoteRepository repo) async {
  final db = await repo.db;
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  final out = <CachedPost>[];
  for (final row in rows) {
    final payload = row['payload'] as String? ?? '{}';
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      out.add(CachedPost.fromJson(map));
    } catch (_) {
      // payload rusak di-skip, bukan crash seluruh list.
      continue;
    }
  }
  return out;
}

// simpan hasil jaringan ke tabel cached_posts untuk kunjungan berikutnya.
Future<void> saveCachedPosts(
  NoteRepository repo,
  List<CachedPost> posts,
) async {
  final db = await repo.db;
  final batch = db.batch();
  batch.delete('cached_posts');
  for (final post in posts) {
    batch.insert('cached_posts', {
      'id': post.id,
      'payload': jsonEncode({
        'id': post.id,
        'title': post.title,
        'body': post.body,
      }),
      'cached_at': DateTime.now().toIso8601String(),
    });
  }
  await batch.commit(noResult: true);
}

// refresh dari jaringan di background.
// jika forceOffline true atau jaringan gagal, cache lama dipertahankan
// dan exception dibiarkan naik agar provider bisa tampilkan state error
// tanpa menghapus cache yang sudah ada.
Future<List<CachedPost>> refreshPostsFromNetwork(
  Dio dio,
  NoteRepository repo, {
  bool forceOffline = false,
}) async {
  if (forceOffline) {
    throw DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );
  }
  final response = await dio.get<List>(
    '/posts',
    queryParameters: {'_limit': 20},
  );
  final data = response.data ?? [];
  final posts = data
      .whereType<Map<String, dynamic>>()
      .map(CachedPost.fromJson)
      .toList();
  await saveCachedPosts(repo, posts);
  return posts;
}
