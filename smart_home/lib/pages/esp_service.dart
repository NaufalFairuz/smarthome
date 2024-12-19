import 'package:http/http.dart' as http;
import 'dart:async';

class EspService {
  final String baseUrl;
  static const int _timeoutDuration = 10; // Durasi timeout dalam detik

  // Konstruktor menerima base URL ESP8266
  EspService(String baseUrl)
      : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl {
    if (Uri.tryParse(this.baseUrl)?.isAbsolute != true) {
      throw ArgumentError('Base URL tidak valid: $this.baseUrl');
    }
  }

  // Fungsi untuk memeriksa koneksi ke ESP8266
  Future<bool> checkConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/ping'); // Endpoint khusus untuk cek koneksi
      print('Memeriksa koneksi ke: $uri');

      // Kirim HTTP GET request
      final response = await http.get(uri).timeout(Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        print('Terhubung ke ESP8266');
        return true;
      } else {
        print('Gagal terhubung ke ESP8266. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('Timeout: Tidak dapat terhubung ke $baseUrl dalam $_timeoutDuration detik.');
      return false;
    } catch (e) {
      print('Kesalahan tidak terduga: $e');
      return false;
    }
  }

  // Fungsi untuk mengirim perintah ke ESP8266 (untuk kontrol lampu, servo)
  Future<bool> sendCommand(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      print('Mengirim permintaan ke: $uri');

      final response = await http.get(uri).timeout(Duration(seconds: _timeoutDuration));

      if (response.statusCode == 200) {
        print('Perintah "$endpoint" berhasil dikirim ke $baseUrl');
        return true;
      } else {
        print('Gagal mengirim perintah "$endpoint". Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } on TimeoutException {
      print('Timeout: Tidak dapat terhubung ke $baseUrl dalam $_timeoutDuration detik.');
      return false;
    } catch (e) {
      print('Kesalahan tidak terduga: $e');
      return false;
    }
  }
}
