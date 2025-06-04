import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final int userId; // L'id que tu récupères depuis le login ou autre

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isQrLarge = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse(
      'http://192.168.1.118/api/profile/get_user?user_id=${widget.userId}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data.containsKey('error')) {
        setState(() {
          userData = data;
        });
      } else {
        print("Erreur backend : ${data['error']}");
      }
    } else {
      print("Erreur réseau : ${response.statusCode}");
    }
  }

  String generateQrData() {
    return '''
Email: ${userData?['email']}
Username: ${userData?['username']}
Match: ${userData?['match_name']}
Stadium: ${userData?['stadium_location']}
Seat: ${userData?['seat_number']}
''';
  }

  @override
  Widget build(BuildContext context) {
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
              Text("Username: ${userData!['username']}"),
              Text("Email: ${userData!['email']}"),
              Text("Match: ${userData!['match_name']}"),
              Text("Stadium: ${userData!['stadium_location']}"),
              Text("Seat: ${userData!['seat_number']}"),
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
