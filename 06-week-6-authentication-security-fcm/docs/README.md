## 🤖 AI Challenge

### Prompt yang Digunakan

> Aplikasi Flutter Campus Notification App. Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod. Buatkan PushService dengan: requestPermission + getToken + onTokenRefresh (kirim ke POST /devices), onMessage (tampilkan local notification manual), onMessageOpenedApp + getInitialMessage (navigasi ke data.route), subscribe/unsubscribe topic pengumuman-kampus, background handler top-level dengan @pragma('vm:entry-point'). Tandai bagian yang BERBEDA untuk Android 13+ vs iOS, dan bagian yang tidak boleh mengakses BuildContext.

### Hasil Generate AI

| File                  | Fungsi                                                                                 |
| --------------------- | -------------------------------------------------------------------------------------- |
| token_store.dart    | TokenStore: save/readAccess/readRefresh/clear hanya via secure storage               |
| auth_repository.dart| AuthSession + mock login/refresh, siap diganti Firebase Auth                         |
| api_client.dart     | Interceptor 401: refresh sekali, ulangi request, clear bila refresh ikut mati         |
| auth_provider.dart  | AuthNotifier login/logout + guard route GoRouter                                     |
| push_service.dart   | Permission, getToken, onTokenRefresh, 3 handler state, topic, background top-level    |

### Alur Kerja


LoginPage (email + password)
│
├── AuthNotifier.login()  →  session → TokenStore.save()
│ │
│ ▼
│ HomePage: token terpotong (debug) + token penuh (ketuk salin)
│ │
│ ├── initFcmToken()  →  getToken → POST /devices → onTokenRefresh pantau
│ │
│ └── campaign Console → banner (background) → klik → data.route → /pengumuman/:id
│
└── 401 dari API  →  refresh sekali  →  retry  →  gagal lagi → clear + /login


### Yang Diperbaiki Manual

1. Background handler berupa method kelas diubah menjadi fungsi top-level dengan @pragma('vm:entry-point').
2. onTokenRefresh yang hanya dicetak ke log diubah agar mengirim token baru ke backend.
3. Foreground yang mengandalkan banner otomatis diubah menjadi local notification manual.
4. initialize() dan show() positional diubah menjadi named sesuai API v22.
5. Token penuh hanya untuk disalin, tidak pernah tampil di screenshot laporan.

### Hasil Test


00:00 +0: routeFromMessage menangani route kosong dan tanpa slash
00:00 +1: data payload membawa id pengumuman
00:00 +2: provider auth membaca status login dari token
00:00 +3: refresh gagal -> sesi dibersihkan (paksa login ulang)
00:00 +4: AnnouncementPage tampilkan id dari route notifikasi
00:00 +5: All tests passed!

