import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

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
  final String id;
  final String name;

  Offer({required this.id, required this.name});

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(id: json['id'].toString(), name: json['name']);
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
        Uri.parse('http://your-backend.com/api/offers'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          offers = data.map((json) => Offer.fromJson(json)).toList();
        });
      } else {
        debugPrint('Failed to fetch offers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching offers: $e');
    }
  }

  void _addOffer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddOfferPage()),
    ).then((_) => _fetchOffers());
  }

  Future<void> _deleteOffer(String offerId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://your-backend.com/api/offers/$offerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
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
                            title: Text(offer.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteOffer(offer.id);
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
      appBar: AppBar(title: const Text('Sponsor Homepage')),
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
  final TextEditingController _nameController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadOffer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name and select an image'),
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final uri = Uri.parse('http://your-backend.com/api/offers');
      final request = http.MultipartRequest('POST', uri);

      final mimeTypeData = lookupMimeType(_image!.path)!.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      request.fields['name'] = name;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add offer: $responseBody')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Offer')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Offer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _uploadOffer,
                child: const Text('Save Offer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
