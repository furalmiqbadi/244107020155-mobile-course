import '../../../../core/failures.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });
  Future<void> deleteNote(int id);
  Future<Note?> fetchNoteById(int id);
  Future<int> countDirty();
  Future<void> markAllSynced();
}
