import 'package:dio/dio.dart';

// ui cuma terima pesan, bukan exception mentah
String friendlyApiMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server kampus.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) {
          return 'Sesi kedaluwarsa. Silakan login ulang.';
        }
        if (code == 404) return 'Data tidak ditemukan (404).';
        return 'Server bermasalah ($code). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  final msg = error.toString();
  // jangan bocorkan token ke ui, potong bila ada jejak bearer
  if (msg.contains('Bearer ')) return 'Sesi tidak valid. Silakan login ulang.';
  return msg.replaceFirst('Exception: ', '');
}
