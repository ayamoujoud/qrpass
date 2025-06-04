import 'package:flutter/material.dart';
import 'package:qrpass/main.dart';
import 'package:qrpass/page/Homepage.dart';

class LogoutPage extends StatelessWidget {
  final String username; // Add this

  const LogoutPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("asset/image/symbole.png"),
        actions: [
          TextButton(
            onPressed: () {
              // You can handle the logout logic here
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                (route) => false, // This will clear the navigation stack
              );
            },
            child: const Text(
              "Log Out",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 19, 18, 18),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 3, 99, 19)),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: Color.fromARGB(255, 232, 240, 232),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "Do you really want to log out from Qrpass?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 164, 36, 36),
                          foregroundColor: Color.fromARGB(255, 18, 6, 5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Handle logout action
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                            (route) => false, // Clear all previous routes
                          );
                        },
                        child: const Text(
                          "Log Out",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 249, 246, 246),
                          foregroundColor: Color.fromARGB(255, 18, 6, 5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Handle logout action
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (route) => false, // Clear all previous routes
                          );
                        },
                        child: const Text(
                          "cancel",
                          style: TextStyle(fontSize: 16),
                        ),
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
