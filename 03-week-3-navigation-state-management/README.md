## Refactoring dan testing
### Checklist Verifikasi Mandiri
- [x] **Navigasi GoRouter**: Berhasil pindah halaman (ToDo <-> Stats) via NavigationBar, state Riverpod tetap bertahan karena ProviderScope di root.
- [x] **Refactoring Widget**: TodoTile dipisah ke folder `widgets/` untuk menghindari code-smell (file terlalu panjang).
- [x] **Provider Turunan**: Berhasil membuat `unfinishedTodosProvider` menggunakan `.where()` untuk memfilter data secara reaktif.
- [x] **UI AsyncValue**: StatsPage sukses menangani loading, error (dengan retry), dan success.
- [x] **Testing & Quality**: `flutter analyze` bersih dari warning, dan `flutter test` berhasil mensimulasikan interaksi user (nambah tugas).
- [x] **Dokumentasi AI**: Prompt, hasil generate, dan hasil verifikasi disimpan rapi di folder `docs/`.


## Dokumentasi AI
Folder: [Dokumentasi-AI](docs/)

## Tugas dan Refleksi
Folder: [tugas](lib/)
### Refleksi
1. Kapan setState masih cukup, dan kapan state harus naik ke Riverpod? 
    setState masih cocok jika untuk state lokal satu widget misalnya status tombol atau form validation di satu halaman. Tapi jika data harus dibagi ke halaman lain kayak daftar ToDo yang muncul di Home dan dihitung di Stats maka pakai Riverpod.
2. Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?
    context.go() itu menggantikan stack navigasi misalnya user tidak dapat back ke halaman sebelumnya. Ini cocok untuk pindah antar tab utama. Sedangkan context.push() itu menumpuk halaman baru di atas stack misalnya user dapat melakukan back pas. Ini cocok untuk buka halaman detail atau alur form multi-step.
3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?
    Tiga boolean (isLoading, hasError, hasData) bisa bikin kondisi ambigu misalnya loading dan error barengan. Oleh karena itu AsyncValue memaksa mengatasinya dengan state secara eksplisit dengan .when(), jadi hanya bisa jadi salah satu kondisi aja. Jadi jika lupa handle salah satu maka compiler langsung error dan aplikasi tidak bisa di-build
4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
    Menambahkan dependency_overrides karena ada package yang tidak cocok dengan versi Flutter. Kemudian memisahkan kode ListTile jadi widget sendiri agar lebih rapi dan mudah di-maintain.

### Checklist Verifikasi
- [x] **Navigasi GoRouter**: Berhasil pindah halaman (ToDo <-> Stats) via NavigationBar, state Riverpod tetap bertahan karena ProviderScope di root.
- [x] **Refactoring Widget**: TodoTile dipisah ke folder `widgets/` untuk menghindari code-smell (file terlalu panjang).
- [x] **Provider Turunan**: Berhasil membuat `unfinishedTodosProvider` menggunakan `.where()` untuk memfilter data secara reaktif.
- [x] **UI AsyncValue**: StatsPage sukses menangani loading, error (dengan retry), dan success.
- [x] **Testing & Quality**: `flutter analyze` bersih dari warning, dan `flutter test` berhasil mensimulasikan interaksi user (nambah tugas).
- [x] **Dokumentasi AI**: Prompt, hasil generate, dan hasil verifikasi disimpan rapi di folder `docs/`.
