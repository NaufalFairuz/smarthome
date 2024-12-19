import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_services.dart'; // File auth_services.dart kamu

class SettingsPage extends StatelessWidget {
  final AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Mendapatkan UID pengguna yang sedang login
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              String userId = user.uid;

              try {
                // Hapus akun dari Firebase Authentication
                await user.delete();

                // Hapus data pengguna dari Realtime Database
                await authServices.deleteUser(userId);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Akun dan data berhasil dihapus!')),
                );

                // Arahkan pengguna ke halaman login atau keluar dari aplikasi
                Navigator.of(context).pushReplacementNamed('/login'); // Ganti dengan nama route halaman login
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus akun: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tidak ada pengguna yang login')),
              );
            }
          },
          child: Text('Hapus Akun'),
        ),
      ),
    );
  }
}
