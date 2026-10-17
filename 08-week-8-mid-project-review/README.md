# notes-validation
File: notes-validation

# Tugas utama
File: main
<img src="screenshots/analyze.png" alt="analyze" style="max-width: 500px; width: 100%;"/>
<img src="screenshots/test.png" alt="test" style="max-width: 500px; width: 100%;"/>
<img src="screenshots/format.png" alt="format" style="max-width: 500px; width: 100%;"/>
<img src="screenshots/pr-merged.png" alt="pr-merged" style="max-width: 500px; width: 100%;"/>

---

# Status Paruh Semester

Aplikasi berjalan identik dengan akhir Minggu 7. Tiga pemeriksaan mesin hijau: analyze bersih, format rapi, test 6/6 lolos. PR kecil validasi judul sudah di-merge via review.

## Peta Issue dan PR

| Item | Status | Keterangan |
|------|--------|------------|
| Issue: simpan catatan tanpa judul | Ditutup | PR feature/notes-validation |
| PR: feat(notes): validasi judul kosong + test | Di-merge | Develop via review sejawat |
| CI: analyze + test otomatis | Aktif | .github/workflows/ci.yml |

## Hasil Mesin

1. flutter analyze: No issues found!
2. dart format --set-exit-if-changed: bersih
3. flutter test: All tests passed! (6/6)

# Refleksi
1. Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?
   LGTM buta hanya membaca judul, sedangkan approve yang bertanggung jawab menjalankan aplikasi dan memeriksa test. Risikonya bagi tim adalah bug lolos ke production dan kualitas menurun tanpa disadari.
2. Kapan komentar wajib berstatus request changes, dan kapan cukup saran?
   Request changes wajib untuk blocker seperti validasi hilang dan bug kebenaran. Cukup saran untuk gaya yang dapat diotomatisasi formatter.
3. Bagian mana dari review AI yang ditolak atau disederhanakan, dan mengapa?
   Usulan use case per CRUD sebaris ditolak karena over-engineering. Usulan validasi judul diterima karena terbukti dengan test repository palsu.
4. Satu hal konkret yang diperbaiki setelah review sejawat, apa dampaknya?
   Validasi judul kosong dipindah dari UI ke use case AddNote. Dampaknya aturan bisnis terpusat, dapat diuji tanpa widget, dan UI tidak bisa melewatinya.


