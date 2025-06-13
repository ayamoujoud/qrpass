import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // QR Scanner
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (capture) {
              final barcode = capture.barcodes.first.rawValue;
              if (barcode != null && !scanned) {
                handleQrCode(barcode);
              }
            },
          ),

          // "Scan QR Code" text
          Positioned(
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Red scanning square
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  void handleQrCode(String code) async {
    if (scanned) return;

    setState(() {
      scanned = true;
    });

    try {
      final data = json.decode(code);
      final email = data['email'];
      final match = data['match'];
      final zone = data['zone'];
      final type = data['type'];

      if (email == null) {
        _showMessage("QR invalide ❗", Colors.orange);
      } else {
        final alreadyUsed = await isTicketUsed(email);
        if (alreadyUsed) {
          _showTicketInfo(
            title: "Billet déjà utilisé ❌",
            color: Colors.red,
            email: email,
            match: match,
            zone: zone,
            type: type,
          );
        } else {
          await markTicketAsUsed(email);
          _showTicketInfo(
            title: "Billet validé ✅",
            color: Colors.green,
            email: email,
            match: match,
            zone: zone,
            type: type,
          );
        }
      }
    } catch (e) {
      _showMessage("QR non reconnu ❗", Colors.orange);
    }

    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      scanned = false;
    });
  }

  Future<bool> isTicketUsed(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(email) ?? false;
  }

  Future<void> markTicketAsUsed(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(email, true);
  }

  void _showMessage(String message, Color color) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: color,
            title: Text(message, style: const TextStyle(color: Colors.white)),
          ),
    );
  }

  void _showTicketInfo({
    required String title,
    required Color color,
    required String email,
    String? match,
    String? zone,
    String? type,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: color,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email: $email",
                  style: const TextStyle(color: Colors.white),
                ),
                if (match != null)
                  Text(
                    "Match: $match",
                    style: const TextStyle(color: Colors.white),
                  ),
                if (zone != null)
                  Text(
                    "Zone: $zone",
                    style: const TextStyle(color: Colors.white),
                  ),
                if (type != null)
                  Text(
                    "Type: $type",
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
