import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../../../data/sync.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

// notifier daftar catatan
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.notes;
  }

  // fungsi tambah lalu muat ulang
  Future<void> addNote(String title, String body) async {
    final repo = ref.read(noteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await AddNote(repo).call(title: title, body: body);
      if (result.failure != null) throw Exception(result.failure!.message);
      final fresh = await GetNotes(repo).call();
      if (fresh.failure != null) throw Exception(fresh.failure!.message);
      return fresh.notes;
    });
  }

  // fungsi hapus lalu muat ulang
  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final failure = await DeleteNote(repo).call(id);
      if (failure != null) throw Exception(failure.message);
      final fresh = await GetNotes(repo).call();
      if (fresh.failure != null) throw Exception(fresh.failure!.message);
      return fresh.notes;
    });
  }

  // fungsi sync lalu muat ulang
  Future<int> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    final synced = await syncNotes(repo);
    ref.invalidateSelf();
    return synced;
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

// fungsi hitung badge dirty
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final notes = ref.watch(notesProvider).value;
  if (notes != null) return notes.where((n) => n.dirty).length;
  return ref.watch(noteRepositoryProvider).countDirty();
});

// fungsi ambil satu catatan buat halaman detail
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  return ref.watch(noteRepositoryProvider).fetchNoteById(id);
});
