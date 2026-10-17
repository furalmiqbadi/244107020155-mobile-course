import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

// fungsi hapus satu catatan
class DeleteNote {
  const DeleteNote(this._repository);
  final NoteRepository _repository;

  Future<Failure?> call(int id) async {
    try {
      await _repository.deleteNote(id);
      return null;
    } catch (e) {
      return LocalFailure('Gagal menghapus catatan: $e');
    }
  }
}
