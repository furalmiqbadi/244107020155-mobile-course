# AI Review vs Keputusan Final

## Prompt yang Digunakan

Review PR Flutter ini sebagai senior Flutter dev. Konteks: feature-first Clean Architecture (presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio. Fokus: kebenaran, arsitektur, dan test. Abaikan style. Berikan 5 temuan teratas + level (blocker/saran) + alasan + usulan potongan kode perbaikan.

## Temuan AI vs Keputusan

| Temuan AI | Level | Keputusan | Alasan |
|-----------|-------|-----------|--------|
| AddNote tidak validasi judul kosong | Blocker | Diterima | Pengguna bisa simpan catatan tanpa judul, UI jadi membingungkan |
| Validasi harus di use case, bukan UI | Saran | Deterima | Aturan bisnis di domain, UI hanya menampilkan failure |
| Test harus memakai repository palsu | Saran | Diterima | Domain diuji murni tanpa SQLite |
| dart format wajib di CI | Saran | Diterima | Mencegah debat spasi di review |
| Jangan tambah use case per CRUD sebaris | Blocker ( AI menolak ) | Diterima | Over-engineering untuk tim kecil |

## Bukti

- Validasi diuji dengan AddNote menolak spasi kosong tanpa menyentuh repository.
- flutter analyze bersih, flutter test 6/6 lolus.
- PR kecil di bawah 300 baris perubahan.
