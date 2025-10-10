// File: lib/pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:movie_finder/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fungsi untuk handle logout, kita letakkan di sini
    void _handleLogout() async {
      // Hapus data login dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      // Kembali ke halaman Login
      // 'mounted' check is a good practice for async operations
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false, // Hapus semua rute sebelumnya
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
            onPressed: _handleLogout, // Panggil fungsi logout saat ditekan
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Beri warna merah agar jelas
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50), // Buat tombol lebih besar
            ),
          ),
        ),
      ),
    );
  }
}