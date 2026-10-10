## 🤖 AI Challenge

### Prompt yang Digunakan

> Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. Requirements: Kriteria kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing. Beri rekomendasi final mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel. Tunjukkan skema tabel/kotak untuk 1000+ catatan. Jelaskan trade-off setiap pilihan.

### Hasil Generate AI

| File                  | Fungsi                                                                                       |
| --------------------- | -------------------------------------------------------------------------------------------- |
| prefs.dart          | PrefsRepository (SharedPreferences) + DarkModeNotifier buat tema dan terakhir dibuka     |
| note.dart           | Model Note + fromMap aman null, flag dirty buat antrean sync                           |
| db.dart             | openNotesDb() + tabel notes dan cached_posts                                           |
| note_repository.dart| CRUD + countDirty + markAllSynced, constructor injeksi openDb agar mudah diuji      |
| sync.dart           | syncNotes() + cache-first readCachedPosts/saveCachedPosts, aturan last-write-wins      |
| providers.dart      | notesProvider, dirtyCountProvider, forceOfflineProvider, cachedPostsProvider          |
| note_test.dart      | 4 test: model field hilang, dirty round-trip, provider sukses/error palsu                    |

### Alur Kerja


NotesPage (ConsumerWidget)
│
├── ref.watch(notesProvider)  →  AsyncValue (loading/error/data)
│ │
│ ▼
│ NotesNotifier.build()  →  fetchNotes() ORDER BY updated_at DESC
│ │
│ ├── tambah? → addNote(dirty=1) → badge "N belum tersinkron"
│ │
│ └── sync? → syncNotes() → countDirty → delay → markAllSynced → badge nol
│
├── Force offline ON? → refresh jaringan diskip, cache lama tetap tampil
│
└── Cache posts → readCachedPosts() dulu → refresh Dio background → saveCachedPosts()


### Yang Ditolak Manual

1. Catatan ditaruh SharedPreferences, ditolak karena satu JSON besar mudah korup dan tidak dapat diquery.
2. CRUD polos tanpa dirty dan updated_at, ditolak karena tanpa itu tidak ada antrean sync dan konflik menimpa data tanpa disadari.
3. Pakai Drift agar real-time, ditolak karena invalidate provider sudah cukup dan tidak perlu build_runner.

### Hasil Test


00:00 +0: fromMap aman terhadap field yang hilang
00:00 +1: flag dirty bertahan pada serialisasi
00:00 +2: provider sukses dengan repository palsu
00:00 +3: provider error dengan repository palsu
00:00 +4: NoteTile menampilkan badge belum tersinkron bila dirty
00:00 +5: NoteTile menampilkan tersinkron bila bersih
00:01 +6: All tests passed!

