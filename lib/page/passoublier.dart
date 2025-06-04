import 'package:flutter/material.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController recoveryController = TextEditingController();

  void _sendRecoveryLink() {
    final input = recoveryController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer votre e-mail")),
      );
      return;
    }

    // Here you can implement actual recovery logic

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lien de récupération envoyé !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 135, 45),
      appBar: AppBar(
        title: const Text('Problèmes de connexion ?'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Vous avez des problèmes de connexion ?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Entrez votre adresse e-mail, et nous vous enverrons un lien pour récupérer votre compte.',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: recoveryController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  hintText: "E-mail",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _sendRecoveryLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Envoyer un lien de connexion",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  // Optional extra recovery help
                },
                child: const Text(
                  "Vous ne parvenez pas à réinitialiser votre mot de passe ?",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
