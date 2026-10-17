import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/add_note.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.saved = const []});

  final List<Note> saved;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: saved, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final note = Note(
      id: saved.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime(2026, 9, 27),
      dirty: true,
    );
    return (note: note, failure: null);
  }

  @override
  Future<void> deleteNote(int id) => Future.value();

  @override
  Future<Note?> fetchNoteById(int id) => Future.value(null);

  @override
  Future<int> countDirty() => Future.value(0);

  @override
  Future<void> markAllSynced() => Future.value();
}

void main() {
  test('AddNote menolak judul kosong tanpa menyentuh repository', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo).call(title: '   ');
    expect(result.failure, isA<LocalFailure>());
    expect(result.note, isNull);
    expect(repo.saved, isEmpty);
  });

  test('AddNote menyimpan judul yang sudah di-trim', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo).call(title: '  Belanja  ');
    expect(result.failure, isNull);
    expect(result.note!.title, 'Belanja');
  });
}
