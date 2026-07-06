import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'pages/auth/login_page.dart';
import 'pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.loadToken(); // cek apakah ada token Sanctum tersimpan
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Pendaftaran Pasien Klinik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      // Jika token tersimpan (pernah login), langsung ke Home.
      // Jika belum, arahkan ke Login. Token tetap akan divalidasi
      // oleh server pada setiap request (401 -> Sesi berakhir).
      home: ApiClient.isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
