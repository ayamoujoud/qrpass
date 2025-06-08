import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewOffersPage extends StatefulWidget {
  const ViewOffersPage({Key? key}) : super(key: key);

  @override
  State<ViewOffersPage> createState() => _ViewOffersPageState();
}

class _ViewOffersPageState extends State<ViewOffersPage> {
  List<dynamic> offers = [];

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.22:8080/qrpass-backend/api/sponsorOffer'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> offerList = json.decode(response.body);
        setState(() {
          offers = offerList;
        });
      } else {
        debugPrint('Failed to load offers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading offers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offres disponibles')),
      body:
          offers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return Card(
                    margin: const EdgeInsets.all(12.0),
                    child: ListTile(
                      leading: const Icon(
                        Icons.local_offer,
                      ), // No image in JSON, so simple icon
                      title: Text(offer['title'] ?? 'No Title'),
                      subtitle: Text(offer['description'] ?? ''),
                      trailing:
                          offer['promoCode'] != null
                              ? Text(
                                offer['promoCode'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              )
                              : null,
                    ),
                  );
                },
              ),
    );
  }
}
