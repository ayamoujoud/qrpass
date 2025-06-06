import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String? errorMessage;
  bool isQrLarge = false;
  File? _imageFile;

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    loadEmailAndFetchData();
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profileImagePath');
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _imageFile = File(savedPath);
      });
    }
  }

  Future<void> loadEmailAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');

    if (savedEmail == null) {
      setState(() {
        errorMessage = "Aucun email trouvé. Veuillez vous reconnecter.";
      });
      return;
    }

    await fetchUserData(savedEmail);
  }

  Future<void> fetchUserData(String email) async {
    try {
      final url = Uri.parse(
        'http://192.168.1.118:8080/qrpass-backend/api/profile?email=$email',
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
            errorMessage = "Erreur du serveur : ${data['error']}";
          });
        }
      } else {
        setState(() {
          errorMessage = "Erreur réseau : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur : $e";
      });
    }
  }

  String generateQrData() {
    if (userData == null) return '';

    // Récupérer le premier ticket (s'il existe)
    final tickets = userData!['tickets'] as List<dynamic>? ?? [];
    final ticket = tickets.isNotEmpty ? tickets.first : null;

    return json.encode({
      'email': userData!['email'],
      'username': userData!['username'],
      'match': ticket != null ? ticket['activity_name'] : '',
      'stadium':
          '', // Pas de champ stadium dans JSON, tu peux adapter si tu en as
      'seat': ticket != null ? ticket['seat'] : '',
      'zone': ticket != null ? ticket['zone'] : '',
    });
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImagePath', pickedImage.path);

        setState(() {
          _imageFile = File(pickedImage.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      _isPickingImage = false;
    }
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

    // Récupérer le premier ticket pour afficher ses données
    final tickets = userData!['tickets'] as List<dynamic>? ?? [];
    final ticket = tickets.isNotEmpty ? tickets.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      backgroundColor: const Color.fromARGB(255, 12, 135, 45),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : const NetworkImage(
                                'https://images.unsplash.com/photo-1603415526960-f8f0f6465c86?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
                              )
                              as ImageProvider,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isPickingImage ? null : _pickImage,
                  child: const Text('Changer la photo de profil'),
                ),
                const SizedBox(height: 20),
                Text(
                  "Username: ${userData!['username']}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Zone: ${ticket != null ? ticket['zone'] : 'N/A'}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Email: ${userData!['email']}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Match: ${ticket != null ? ticket['activity_name'] : 'N/A'}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Stadium: N/A", // Aucun champ stadium dans JSON donné
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Seat: ${ticket != null ? ticket['seat'] : 'N/A'}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
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
      ),
    );
  }
}
