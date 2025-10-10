import 'package:flutter/material.dart';
import 'package:movie_finder/helpers/database_helper.dart';
import 'package:movie_finder/pages/home_page.dart';
import 'package:movie_finder/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // BARU: State untuk menyimpan nilai checkbox
  bool _rememberMe = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.getUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // BARU: Logika untuk menyimpan atau menghapus data login
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          // Jika checkbox dicentang, simpan userId
          await prefs.setInt('userId', user['id'] as int);
        } else {
          // Jika tidak dicentang, hapus userId yang mungkin sudah ada
          await prefs.remove('userId');
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: user['id'] as int)),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Wrong Email or Password.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Welcome to Movie Finder!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email Cant Be Empty';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password Cant Be Empty';
                    return null;
                  },
                ),
                // BARU: Checkbox "Ingat Saya" ditambahkan
                CheckboxListTile(
                  title: const Text("Keep Me Logged In"),
                  value: _rememberMe,
                  onChanged: (newValue) {
                    setState(() {
                      _rememberMe = newValue ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading, // Checkbox di sebelah kiri
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _handleLogin,
                  child: const Text('LOGIN'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('Dont Have Account? Register Here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}