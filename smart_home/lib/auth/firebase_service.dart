import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  final String databaseURL = "https://smarthome-efa61-default-rtdb.firebaseio.com/";

  // Fungsi untuk mendaftarkan pengguna baru dengan email dan password
  Future<void> registerUser(String email, String password) async {
    final url = Uri.parse('$databaseURL/users.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password, // Simpan password
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        print("User registered successfully");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to register user: $e");
    }
  }

  // Fungsi untuk login dengan email dan password
  Future<bool> loginUser(String email, String password) async {
    final url = Uri.parse('$databaseURL/users.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          // Cek apakah email dan password cocok
          for (var user in data.values) {
            if (user['email'] == email && user['password'] == password) {
              return true;
            }
          }
        }
        return false; // Tidak ditemukan
      } else {
        print("Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Failed to login user: $e");
      return false;
    }
  }
}
