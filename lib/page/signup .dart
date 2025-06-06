import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qrpass/page/Homepage.dart';
import 'package:qrpass/page/orghomepage.dart';
import 'package:qrpass/page/sponser.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSponsor = false;
  bool _isOrganizer = false;
  bool _isSpectator = false;
  bool _isLoading = false;

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
          suffixIcon:
              toggleObscure != null
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: toggleObscure,
                  )
                  : null,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message, Widget targetPage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Success"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => targetPage),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (!email.contains('@')) {
      _showErrorDialog('Please enter a valid email');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    if (!_isSponsor && !_isOrganizer && !_isSpectator) {
      _showErrorDialog('Please select a role');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.118:8080/qrpass-backend/api/register"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': email,
          'password': password,
          'role':
              _isSpectator
                  ? 'spectateur'
                  : _isOrganizer
                  ? 'organisateur'
                  : 'sponsor',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        Widget nextPage;

        if (_isOrganizer) {
          nextPage = OrganizerHomePage();
        } else if (_isSpectator) {
          nextPage = HomePage();
        } else {
          nextPage = SponsorHomePage();
        }

        _showSuccessDialog(
          data['message'] ?? 'Registration successful!',
          nextPage,
        );
      } else {
        _showErrorDialog(data['message'] ?? 'Registration failed.');
      }
    } catch (e) {
      _showErrorDialog('Network error. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 135, 45),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              child: Image.network(
                "https://pbs.twimg.com/tweet_video_thumb/GiNIS_eXEAAao4R.jpg",
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Create an Account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome! Let's get you set up.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  buildTextField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    controller: passwordController,
                    hintText: "Password",
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    toggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    icon: Icons.lock,
                    obscureText: _obscureConfirmPassword,
                    toggleObscure: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isSponsor,
                        onChanged: (value) {
                          setState(() {
                            _isSponsor = value!;
                            _isOrganizer = false;
                            _isSpectator = false;
                          });
                        },
                      ),
                      const Text("Sponsor"),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: _isOrganizer,
                        onChanged: (value) {
                          setState(() {
                            _isOrganizer = value!;
                            _isSponsor = false;
                            _isSpectator = false;
                          });
                        },
                      ),
                      const Text("Organizer"),
                      const SizedBox(width: 12),
                      Checkbox(
                        value: _isSpectator,
                        onChanged: (value) {
                          setState(() {
                            _isSpectator = value!;
                            _isSponsor = false;
                            _isOrganizer = false;
                          });
                        },
                      ),
                      const Text("Spectator"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
