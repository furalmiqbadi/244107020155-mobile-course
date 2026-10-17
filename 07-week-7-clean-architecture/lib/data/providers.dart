import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notes/data/repositories/note_repository_impl.dart';
import 'local/db.dart';
import 'prefs.dart';
import 'sync.dart';

// dio terpusat, dipakai ulang dari pola minggu 4
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));
  return dio;
});

// preferensi
final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

// saklar pura-pura offline biar demo nggak tergantung wifi kelas
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

// cache-first buat data api
final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<CachedPost>>(
      CachedPostsNotifier.new,
    );

class CachedPostsNotifier extends AsyncNotifier<List<CachedPost>> {
  NoteRepositoryImpl _repo() => NoteRepositoryImpl(openDb: openNotesDb);

  @override
  Future<List<CachedPost>> build() async {
    final repo = _repo();
    final dio = ref.watch(dioProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    // 1. baca cache lokal dulu agar UI tidak blank saat offline.
    final cached = await readCachedPosts(repo);

    // 2. refresh background kecuali forceOffline.
    if (!forceOffline) {
      try {
        final fresh = await refreshPostsFromNetwork(dio, repo);
        return fresh;
      } catch (_) {
        // jaringan gagal, pertahankan cache lama.
        return cached;
      }
    }
    return cached;
  }

  Future<void> refresh() async {
    final repo = _repo();
    final dio = ref.read(dioProvider);
    final forceOffline = ref.read(forceOfflineProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (forceOffline) {
        // tetap tampilkan cache saat dipaksa offline.
        return readCachedPosts(repo);
      }
      try {
        return await refreshPostsFromNetwork(dio, repo);
      } catch (_) {
        return readCachedPosts(repo);
      }
    });
  }
}
