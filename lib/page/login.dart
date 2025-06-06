import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qrpass/page/Homepage.dart';
import 'package:qrpass/page/orghomepage.dart';
import 'package:qrpass/page/sponser.dart';
import 'package:qrpass/page/passoublier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both email and password');
      return;
    }

    if (!email.contains('@')) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.118:8080/qrpass-backend/api/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          _showErrorDialog('Server returned empty response.');
          return;
        }

        Map<String, dynamic> data;
        try {
          data = json.decode(response.body);
        } catch (e) {
          _showErrorDialog('Invalid response format from server.');
          return;
        }

        if (data['success'] == true) {
          final role = data['role'] as String?;
          if (role == null) {
            _showErrorDialog('Role information missing in response.');
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);
          await prefs.setString('userRole', role);

          if (!mounted) return;

          Widget targetPage;
          if (role == 'spectateur') {
            targetPage = const HomePage();
          } else if (role == 'organisateur') {
            targetPage = const OrganizerHomePage();
          } else if (role == 'sponsor') {
            targetPage = const SponsorHomePage();
          } else {
            _showErrorDialog('Unknown role: $role');
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        } else {
          _showErrorDialog(
            data['message'] ?? 'Login failed. Please try again.',
          );
        }
      } else if (response.statusCode == 401) {
        _showErrorDialog('Email or password incorrect.');
      } else if (response.statusCode == 403) {
        _showErrorDialog(dataFromBody(response.body) ?? 'Access forbidden.');
      } else {
        _showErrorDialog('Login failed. Please try again.');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _showErrorDialog('Network error. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? dataFromBody(String body) {
    try {
      final data = json.decode(body);
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
    } catch (_) {}
    return null;
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
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
      backgroundColor: const Color.fromARGB(255, 12, 135, 45),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Image.network(
                      "https://pbs.twimg.com/tweet_video_thumb/GiNIS_eXEAAao4R.jpg",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please login to continue',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.email),
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                      : const Text('LOGIN'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const PasswordRecoveryScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
