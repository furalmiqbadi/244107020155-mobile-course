## 🤖 AI Challenge

### Prompt yang Digunakan

> Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod. Requirements: ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan pengambilan data statistik (delay 2 detik, kadang gagal 30%). UI harus menangani loading, error (pesan + tombol retry), dan success (ListView 3 item). Berikan unit test untuk notifier-nya. Jelaskan setiap bagian kode dalam komentar.

### Hasil Generate AI

| File                       | Fungsi                                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| `stats_provider.dart`      | Model `StatItem` + `StatsNotifier` (AsyncNotifier) dengan delay 2 detik & 30% kemungkinan gagal |
| `stats_page.dart`          | `ConsumerWidget` yang menangani 3 state: loading, error+retry, success (ListView 3 item)        |
| `stats_notifier_test.dart` | 4 unit test untuk notifier (sukses, gagal, retry, model equality)                               |

### Alur Kerja

1
StatsPage (ConsumerWidget)
│
├── ref.watch(statsProvider)
│ │
│ ▼
│ StatsNotifier.build()
│ │
│ ├── delay 2 detik (simulasi jaringan)
│ │
│ ├── random < 0.3? → throw Exception → UI: error + tombol retry
│ │
│ └── random >= 0.3? → return 3 StatItem → UI: ListView
│
└── Tombol "Coba Lagi" → ref.read(...notifier).retry()
1

### Hasil Test

00:00 +0: build() mengembalikan 3 item statistik saat berhasil
00:03 +1: build() melempar exception saat simulasi gagal (< 0.3)
00:06 +2: retry() berhasil setelah error sebelumnya
00:11 +3: StatItem equality bekerja berdasarkan isi, bukan referensi
00:11 +4: All tests passed!
