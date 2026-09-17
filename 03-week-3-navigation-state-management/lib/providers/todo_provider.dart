import 'package:flutter_riverpod/flutter_riverpod.dart';

// model data untuk merepresentasikan satu item tugas
class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  // membuat salinan objek dengan nilai baru untuk menjaga prinsip immutability
  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

// kelas notifier untuk mengelola state daftar tugas secara terpusat
class TodoListNotifier extends Notifier<List<Todo>> {
  // inisialisasi state awal berupa daftar tugas yang kosong
  @override
  List<Todo> build() => const [];

  // menambahkan tugas baru dengan mengembalikan instance list yang baru
  void add(String title) => state = [...state, Todo(title)];

  // mengubah status selesai atau belum pada tugas berdasarkan index
  void toggle(int index) {
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  // menghapus tugas dari daftar berdasarkan index yang dipilih
  void remove(int index) => state = [...state]..removeAt(index);
}

// mendaftarkan notifier sebagai provider agar dapat diakses oleh UI
final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

// provider turunan untuk memfilter dan menampilkan tugas yang belum selesai
final unfinishedTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => !todo.done).toList();
});
