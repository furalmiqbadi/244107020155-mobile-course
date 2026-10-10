import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
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

// ── preferensi ──
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

// ── catatan lokal ──
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  // matikan retry otomatis agar error final dan mudah diuji.
  retry: (retryCount, error) => null,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> addNote(String title, String body) async {
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.addNote(title: title, body: body);
      return repo.fetchNotes();
    });
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repo.deleteNote(id);
      return repo.fetchNotes();
    });
  }

  // sync dirty, refresh list, mengembalikan jumlah yang tersinkron.
  Future<int> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    final synced = await syncNotes(repo);
    ref.invalidateSelf();
    return synced;
  }
}

// badge dirty, dihitung dari list yang sedang tampil agar reaktif.
// fallback ke query DB bila list belum ada (misal saat error).
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final notes = ref.watch(notesProvider).value;
  if (notes != null) return notes.where((n) => n.dirty).length;
  return ref.watch(noteRepositoryProvider).countDirty();
});

// detail membaca dari repository lokal, bukan dari state list
// (refactoring challenge no.3).
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  return ref.watch(noteRepositoryProvider).fetchNoteById(id);
});

// ── simulasi offline deterministik ──
// toggle agar demo/testing tidak bergantung pada Wi-Fi kelas.
// jika true, refresh jaringan dilempar sebagai connectionError.
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
  @override
  Future<List<CachedPost>> build() async {
    final repo = ref.watch(noteRepositoryProvider);
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
    final repo = ref.read(noteRepositoryProvider);
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
