import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan import Firebase
import 'package:smart_home/auth/login_page.dart';
import 'package:smart_home/auth/register_page.dart';
import 'splash_screen_page.dart';
import 'home_page.dart';
import 'firebase_options.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Inisialisasi dengan opsi platform yang benar
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreenPage(), // Menampilkan SplashScreenPage sebagai halaman utama
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
