import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthServices {
  final String databaseURL = "https://smarthome-efa61-default-rtdb.firebaseio.com/";

  // Fungsi untuk menghapus akun berdasarkan userId namun tidak jadi
  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      print("Error: userId is empty");
      return;
    }
    final url = Uri.parse('$databaseURL/users/$userId.json'); // Endpoint pengguna spesifik
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("User deleted successfully: $userId");
      } else {
        print("Failed to delete user: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  // Fungsi untuk mendapatkan semua user
  Future<Map<String, dynamic>> getAllUsers() async {
    final url = Uri.parse('$databaseURL/users.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          print("Unexpected response format");
          return {};
        }
      } else {
        print("Failed to fetch users: ${response.statusCode}, ${response.body}");
        return {};
      }
    } catch (e) {
      print("Error fetching users: $e");
      return {};
    }
  }

  // Fungsi untuk mencari userId berdasarkan email (opsional)
  Future<String?> getUserIdByEmail(String email) async {
    final allUsers = await getAllUsers();
    try {
      for (var entry in allUsers.entries) {
        if (entry.value['email'] == email) {
          return entry.key; // Mengembalikan userId
        }
      }
      print("Email not found: $email");
      return null;
    } catch (e) {
      print("Error searching user by email: $e");
      return null;
    }
  }
}
