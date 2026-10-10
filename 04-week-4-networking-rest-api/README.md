# Week 4 — Networking & REST API
File: [tugas-utama](lib/main.dart)

Aplikasi daftar data dari REST API menggunakan Dio terpusat, repository pattern, dan Riverpod AsyncValue, ditambah pagination infinite scroll.

# Tugas utama
File: [post_list_page](lib/pages/post_list_page.dart) | [paged_post_page](lib/pages/paged_post_page.dart) | [post_detail_page](lib/pages/post_detail_page.dart)
<img src="screenshots/list-success.png" alt="daftar-posts" style="max-width: 300px; width: 100%;"/>

Daftar posts tampil setelah loading, lengkap dengan pull-to-refresh dan Bottom Nav.

## State error + retry
File: [network_errors](lib/data/network_errors.dart)
<img src="screenshots/error-retry.png" alt="error-retry" style="max-width: 300px; width: 100%;"/>

Mmenampilkan pesan "Tidak dapat terhubung ke server" saat tidak ada internet beserta tombol coba lagi.

## Pagination (infinite scroll, 10 per halaman)
File: [paged_posts](lib/data/paged_posts.dart) | [post_repository](lib/data/repositories/post_repository.dart)
<img src="screenshots/paged-scroll.png" alt="paged-scroll" style="max-width: 300px; width: 100%;"/>

Saat scroll mendekati bawah, halaman berikutnya dimuat otomatis. Ada guard agar request ganda tidak terjadi.

---

# AI Prompt Challenge
Folder: [Dokumentasi-AI](docs/)

## Prompt yang dipakai
> Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id} dari JSONPlaceholder menggunakan Dio + flutter_riverpod. Requirements: Model Comment dengan fromJson aman null, CommentRepository dengan fetchComments(postId) + timeout 10 detik, AsyncNotifierProvider dengan penanganan error otomatis dan pesan error ramah pengguna, satu unit test untuk fromJson dengan field yang hilang. Jelaskan setiap bagian kode dalam komentar.

## Hasil generate AI
| File | Fungsi |
|------|--------|
| post.dart | Model Post + fromJson aman null (as num? ?? 0, as String? ?? '') |
| api_client.dart | createDio(): baseUrl, timeout 10 detik, LogInterceptor di satu tempat |
| post_repository.dart | fetchPosts() + fetchPostsPage(page, limit) dengan whereType agar item rusak dilewati |
| providers.dart | PostListNotifier (AsyncNotifier), retry otomatis dimatikan agar error bersifat final dan mudah diuji |
| network_errors.dart | friendlyErrorMessage(): timeout, connection error, 404/401/403/500 menjadi pesan untuk pengguna |

## Verification prompt
Bukti AI Challenge berjalan (Comments App): error saat offline dan sukses menampilkan comments.
<img src="screenshots/ai-comments-offline.png" alt="ai-comments-offline" style="max-width: 300px; width: 100%;"/>
<img src="screenshots/ai-comments-success.png" alt="ai-comments-success" style="max-width: 300px; width: 100%;"/>

## Yang diperbaiki dari hasil AI
1. Cast langsung (json['title']) menjadi cast defensif, karena API dapat mengirim null sehingga aplikasi crash.
2. (res.data as List) menjadi get<List> + ?? [] + whereType, agar satu item rusak tidak merusak seluruh list.
3. Timeout yang awalnya per-method dipusatkan di createDio(), agar skenario baseUrl salah mudah diuji.
4. Error mentah (e.toString()) diganti friendlyErrorMessage() beserta tombol Coba lagi.
5. Test AI yang hanya happy-path ditambah edge case: field hilang, timeout, 404, provider error, provider empty.

## Hasil test

flutter analyze → No issues found!
flutter test → All tests passed! (10/10, tanpa HTTP sungguhan via FakePostRepository)


---

# Refactoring dan testing
### Checklist Verifikasi Mandiri
- [x] UI tidak memanggil Dio langsung, semua akses data lewat repository + provider.
- [x] Empat state tampil benar: loading, error (+ retry), empty, success.
- [x] Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data.
- [x] flutter analyze tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder docs/.

---

# Tugas dan Refleksi
Folder: [tugas](lib/)
### Refleksi
1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?
   Jika UI langsung memanggil Dio, logika seperti parsing, timeout, dan retry akan tersebar ke mana-mana. Akibatnya mengganti konfigurasi jaringan jadi sangat rumit dan testing mustahil dilakukan tanpa internet. Memisahkannya menciptakan satu pintu data yang rapi dan terpusat.
2. Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (_page/_limit)?
   Client-side cukup jika total data kecil dan sudah diunduh sekaligus sehingga scroll terasa mulus. Namun, server-side wajib untuk data berskala besar dan jika mengunduh ribuan data sekaligus hanya akan membebani memori dan membuat aplikasi lambat. Jadi Server-side memastikan aplikasi tetap ringan, responsif, dan hemat kuota.
3. Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?
   Karena AsyncNotifier sehingga metode build() otomatis mengubah hasil sukses menjadi AsyncData dan error menjadi AsyncError. Lalu widget cukup merender dengan .when(). Namun, try/catch manual tetap dibutuhkan saat memuat halaman berikutnya (loadNextPage). Tujuannya untuk menjaga pengalaman pengguna dimana jika gagal data lama tidak hilang dan layar tidak tiba-tiba tertutup pesan error.
4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
   Mungkin memperbaikinya agar lebih stabil contohnya memperketat parsing data agar tidak crash jika menerima tipe data aneh, memusatkan timeout, menerjemahkan pesan error agar ramah pengguna, dan menambah edge case pada testing. 
