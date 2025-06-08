import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'logout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sponsor Offers',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SponsorHomePage(),
    );
  }
}

class SponsorHomePage extends StatefulWidget {
  const SponsorHomePage({Key? key}) : super(key: key);

  @override
  State<SponsorHomePage> createState() => _SponsorHomePageState();
}

class Offer {
  final String title;
  final String description;
  final String promoCode;
  final String startDate;
  final String endDate;

  Offer({
    required this.title,
    required this.description,
    required this.promoCode,
    required this.startDate,
    required this.endDate,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      promoCode: json['promoCode'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }
}

class _SponsorHomePageState extends State<SponsorHomePage> {
  List<Offer> offers = [];

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.22:8080/qrpass-backend/api/sponsorOffer'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          offers = data.map((json) => Offer.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
    }
  }

  Future<void> _deleteOffer(String title) async {
    try {
      final response = await http.delete(
        Uri.parse(
          'http://192.168.8.22:8080/qrpass-backend/api/sponsorOffer?title=$title',
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer deleted successfully')),
        );
        _fetchOffers();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete offer')));
      }
    } catch (e) {
      debugPrint('Error deleting offer: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting offer: $e')));
    }
  }

  void _addOffer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddOfferPage()),
    ).then((_) => _fetchOffers());
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Offer'),
            content:
                offers.isEmpty
                    ? const Text('No offers available')
                    : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return ListTile(
                            title: Text(offer.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteOffer(offer.title);
                              },
                            ),
                          );
                        },
                      ),
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _addOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 80,
                  ),
                ),
                child: const Text('Add Offer'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showDeleteDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 80,
                  ),
                ),
                child: const Text('Delete Offer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOfferPage extends StatefulWidget {
  const AddOfferPage({Key? key}) : super(key: key);

  @override
  State<AddOfferPage> createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _promocodeController = TextEditingController();

  bool _isValidDate(String input) {
    try {
      DateTime.parse(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _uploadOffer() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final startDate = _startDateController.text.trim();
    final endDate = _endDateController.text.trim();
    final promocode = _promocodeController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        startDate.isEmpty ||
        endDate.isEmpty ||
        promocode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_isValidDate(startDate) || !_isValidDate(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid dates in YYYY-MM-DD format'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.8.22:8080/qrpass-backend/api/sponsorOffer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "description": description,
          "promocode": promocode,
          "startDate": startDate,
          "endDate": endDate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add offer: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Add Offer')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date (YYYY-MM-DD)',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _promocodeController,
                  decoration: const InputDecoration(
                    labelText: 'Promo Code',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Offer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
