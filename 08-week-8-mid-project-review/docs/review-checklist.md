# Review Checklist — Mid Project

## Audit Riwayat

| Temuan | Status |
|--------|--------|
| Commit langsung ke main | Ada (minggu 1-7) — dikoreksi dengan branch develop |
| Pesan commit tidak konvensional | Ada (fix bug, update) — ditulis ulang di tabel bawah |
| Branch berumur lebih dari 1 minggu | Tidak ada |
| File tak terlacak | Tidak ada |

## Tabel Commit Sebelum dan Sesudah

| Commit lama | Commit baru (konvensional) | Alasan |
|-------------|---------------------------|--------|
| fix bug | fix(notes): cegah simpan judul kosong + test | Jelas apa, di mana, dan buktinya |
| update | feat(notes): validasi judul di use case AddNote | Satu perubahan logis per commit |
| final fix beneran | test(add_note): uji tolak judul kosong + trim | Test terpisah agar bisa di-revert |

## Hasil Tiga Pemeriksaan Mesin

1. flutter analyze: No issues found!
2. dart format --set-exit-if-changed: bersih
3. flutter test: All tests passed! (6/6)

## Status Kesiapan

Struktur feature-first terbukti (3 grep sterilitas nol dari minggu 7), analyze bersih, test hijau, PR kecil dengan commit jelas, README dan screenshot lengkap.
