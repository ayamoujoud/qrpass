import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String username; // Changed to username

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String? errorMessage;
  bool isQrLarge = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final url = Uri.parse(
        'http://192.168.1.118:8080/api/profile/get_user?username=${widget.username}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!data.containsKey('error')) {
          setState(() {
            userData = data;
            errorMessage = null;
          });
        } else {
          setState(() {
            errorMessage = "Backend error: ${data['error']}";
          });
        }
      } else {
        setState(() {
          errorMessage = "Network error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception: $e";
      });
    }
  }

  String generateQrData() {
    return json.encode({
      'email': userData?['email'],
      'username': userData?['username'],
      'match': userData?['match_name'],
      'stadium': userData?['stadium_location'],
      'seat': userData?['seat_number'],
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      backgroundColor: const Color.fromARGB(255, 12, 135, 45),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                "Username: ${userData!['username']}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Email: ${userData!['email']}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Match: ${userData!['match_name']}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Stadium: ${userData!['stadium_location']}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Seat: ${userData!['seat_number']}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isQrLarge = !isQrLarge;
                  });
                },
                child: QrImageView(
                  data: generateQrData(),
                  size: isQrLarge ? 250 : 100,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
