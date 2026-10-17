## AI Challenge

### Prompt yang Digunakan

Project Flutter: campus_notify (auth + FCM + daftar pengumuman). Kondisi kini: folder lib/{data, providers, pages, messaging}, repository tercampur dengan implementasi, widget memanggil Dio langsung. Tugas: 1. Usulkan struktur feature-first Clean Architecture (presentation/domain/data) untuk fitur auth + announcements. 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus). 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana, dan kapan use case benar-benar dibutuhkan vs repository langsung. 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan). Jelaskan trade-off setiap keputusan.

### Tabel Usulan vs Keputusan Final

| Usulan AI | Keputusan final | Alasan |
|---|---|---|
| Feature-first notes/{domain,data,presentation} | Diterima penuh | Satu fitur bisa dipahami dan dihapus tanpa menyentuh fitur lain |
| Use case untuk tiap CRUD satu-baris | Ditolak, hanya GetNotes/AddNote/DeleteNote yang benar-benar dipakai UI | Use case per operasi sebaris adalah over-engineering bagi tim kecil |
| Either via fpdart/dartz | Ditolak, pakai record Dart (data:, failure:) | Tanpa dependensi tambahan, kontrak sukses/gagal tetap eksplisit |
| DI package tambahan | Ditolak, Riverpod provider cukup | Widget tidak pernah new Repository() sendiri, wiring terpusat di provider |
| Entity bebas mapping | Diterima penuh | toMap/fromMap hanya di NoteModel, domain steril dari SQLite |

### Hasil Tiga Grep Sterilitas

Hasil 1 presentation steril dari data mentah: 0 (harus 0)
Hasil 2 domain steril dari framework dan package: 0 (harus 0)
Hasil 3 flutter analyze dan flutter test: No issues found! + All tests passed! (4/4)

### Hasil Test

GetNotes meneruskan daftar dari repository: lolos
GetNotes meneruskan failure tanpa melempar: lolos
NoteTile menampilkan badge belum tersinkron bila dirty: lolos
NoteTile menampilkan tersinkron bila bersih: lolos
All tests passed!
