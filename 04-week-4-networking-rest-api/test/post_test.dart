import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/data/network_errors.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false})
      : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<List<Post>> fetchPostsPage(
      {required int page, int limit = 10}) async {
    return fetchPosts();
  }
}

void main() {
  group('Post Model Tests', () {
    test('fromJson aman terhadap field yang hilang', () {
      final post = Post.fromJson({'id': 7});
      expect(post.id, 7);
      expect(post.title, '');
      expect(post.userId, 0);
      expect(post.body, '');
    });

    test('fromJson dengan semua field lengkap', () {
      final post = Post.fromJson({
        'userId': 1,
        'id': 42,
        'title': 'Judul Tes',
        'body': 'Isi body',
      });
      expect(post.userId, 1);
      expect(post.id, 42);
      expect(post.title, 'Judul Tes');
      expect(post.body, 'Isi body');
    });

    test('toJson mengembalikan Map yang benar', () {
      const post = Post(
        userId: 1,
        id: 1,
        title: 'Test',
        body: 'Body',
      );
      final json = post.toJson();
      expect(json['userId'], 1);
      expect(json['id'], 1);
      expect(json['title'], 'Test');
      expect(json['body'], 'Body');
    });
  });

  group('Error Message Tests', () {
    test('friendlyErrorMessage untuk connection error', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyErrorMessage(err), contains('terhubung'));
    });

    test('friendlyErrorMessage untuk timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(friendlyErrorMessage(err), contains('timeout'));
    });

    test('friendlyErrorMessage untuk 404', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 404,
        ),
      );
      expect(friendlyErrorMessage(err), contains('404'));
    });
  });

  group('Provider Tests dengan Fake Repository', () {
    test('provider sukses dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: [
              const Post(
                userId: 1,
                id: 1,
                title: 'Tes',
                body: 'Isi',
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final posts = await readPostsOnce(container);
      expect(posts.length, 1);
      expect(posts.first.title, 'Tes');
    });

    test('provider error dengan repository palsu', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final err = await readPostsErrorOnce(container);
      expect(err, isA<DioException>());
      expect(friendlyErrorMessage(err!), contains('terhubung'));
    });

    test('provider dengan data kosong', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: []),
          ),
        ],
      );
      addTearDown(container.dispose);

      final posts = await readPostsOnce(container);
      expect(posts.length, 0);
    });
  });
}
