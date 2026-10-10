import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// fungsi murni ubah data message jadi route, bisa ditest tanpa firebase
String routeFromMessage(Map<String, String> data) {
  final route = data['route'] ?? '/';
  return route.startsWith('/') ? route : '/$route';
}

final _local = FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

// dipanggil pas banner lokal diklik, diisi dari main biar bisa navigasi
void Function(String route)? onNotificationTap;

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;
      final tap = onNotificationTap;
      final route = response.payload;
      if (tap != null && route != null) tap(route);
    },
  );
}

// banner lokal manual buat uji foreground tanpa firebase
Future<void> showTestLocalNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'pengumuman',
    'Pengumuman Kampus',
    importance: Importance.high,
    priority: Priority.high,
    timeoutAfter: 30000,
  );
  await _local.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: 'Jadwal kuliah berubah',
    body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
    notificationDetails: const NotificationDetails(android: androidDetails),
    payload: '/pengumuman/3',
  );
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

Future<void> subscribeCampusTopic() =>
    FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');

Future<void> unsubscribeCampusTopic() =>
    FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');

// ambil token fcm penuh buat disalin, jangan tampil di screenshot
Future<String?> getFcmTokenFull() async {
  for (var i = 0; i < 3; i++) {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      if (i == 2) return null;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  return null;
}

// ambil token fcm terpotong buat halaman debug
Future<String> getFcmTokenPreview() async {
  final token = await getFcmTokenFull();
  if (token == null) return 'Token tidak tersedia';
  return token.length > 12 ? '${token.substring(0, 12)}...' : token;
}

void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(
      message.data.map((k, v) => MapEntry(k, v.toString())),
    );
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
      timeoutAfter: 30000,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    go(routeFromMessage(message.data.map((k, v) => MapEntry(k, v.toString()))));
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    go(routeFromMessage(initial.data.map((k, v) => MapEntry(k, v.toString()))));
  }
  if (pendingDeepLink != null) go(pendingDeepLink!);
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
