## 🤖 AI Challenge

### Prompt yang Digunakan

> Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id} dari JSONPlaceholder menggunakan Dio + flutter_riverpod. Requirements: Model Comment dengan fromJson aman null (postId, id, name, email, body). CommentRepository dengan method fetchComments(postId) + timeout 10 detik. AsyncNotifierProvider dengan penanganan error otomatis (AsyncError) dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500. Satu unit test untuk fromJson dengan field yang hilang. Jelaskan setiap bagian kode dalam komentar.

### Hasil Generate AI

| File                      | Fungsi                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------- |
| post.dart               | Model Post + fromJson aman null, cast lewat num?/String? dengan default 0/''                 |
| api_client.dart         | createDio(): baseUrl, timeout 10 detik, LogInterceptor terpusat                                     |
| post_repository.dart    | fetchPosts() + fetchPostsPage(page, limit) pakai _page/_limit + whereType                      |
| providers.dart          | PostListNotifier (AsyncNotifier) + retry: null + helper readPostsOnce buat testing                 |
| network_errors.dart     | friendlyErrorMessage(): timeout, connectionError, badResponse (404/401/403/500)                        |
| post_test.dart          | 9 test: model field hilang, error mapping, provider sukses/error/kosong pakai FakePostRepository      |

### Alur Kerja


UI (ConsumerWidget)
│
├── ref.watch(postListProvider)  →  AsyncValue (loading/error/data)
│ │
│ ▼
│ PostListNotifier.build()
│ │
│ ├── repository.fetchPosts()  →  Dio GET /posts
│ │
│ ├── sukses? → AsyncData → ListView + PostTile
│ │
│ └── throw? → AsyncError → friendlyErrorMessage + tombol Coba lagi
│
└── Scroll dekat bawah (paged) → fetchPostsPage(page+1) → [...lama, ...baru]
    └── guard: isLoadingMore || !hasMore → skip (no request ganda)


### Yang Diperbaiki Manual

1. Cast langsung → defensif (anti Null is not a subtype).
2. (res.data as List) → get<List> + ?? [] + whereType (item rusak di-skip).
3. Timeout per-method → terpusat di createDio().
4. e.toString() ke UI → friendlyErrorMessage().
5. Test happy-path → tambah edge case (timeout, 404, provider error/empty).

### Hasil Test


00:00 +0: fromJson aman terhadap field yang hilang
00:00 +1: fromJson dengan semua field lengkap
00:00 +2: toJson mengembalikan Map yang benar
00:00 +3: friendlyErrorMessage untuk connection error
00:00 +4: friendlyErrorMessage untuk timeout
00:00 +5: friendlyErrorMessage untuk 404
00:00 +6: provider sukses dengan repository palsu
00:00 +7: provider error dengan repository palsu
00:00 +8: provider dengan data kosong
00:00 +9: PostTile renders post details correctly
00:00 +10: All tests passed!

