import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:qrpass/page/2page.dart'; // Your login screen and others
import 'package:qrpass/page/event_service.dart'; // Your EventService class

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<EventService>(create: (_) => EventService()),
        // Add more providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'qrpass',
      theme: ThemeData(
        fontFamily: 'consolas',
        scaffoldBackgroundColor: const Color(0xFF006400),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Football access, just a scan.",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Empowering your passion for football with seamless access—where every match is just a scan away",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFEDEDED),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Image.network(
                    "https://pbs.twimg.com/tweet_video_thumb/GiNIS_eXEAAao4R.jpg",
                  ),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 234, 41, 41),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEDEDED),
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'By tapping on Get Started, I acknowledge that I have read and agree to the ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle Terms of Service tap
                                },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle Privacy Policy tap
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
