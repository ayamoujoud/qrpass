import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async'; // Added for TimeoutException

class AddEventModal extends StatefulWidget {
  const AddEventModal({super.key});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final TextEditingController _eventNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  File? _image;
  bool _isLoading = false;
  bool _isPickingImage = false;

  Future<void> _pickDate() async {
    if (!mounted) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || !mounted) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (picked != null && mounted) {
        setState(() {
          _image = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image picker error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        'http://192.168.8.22:8080/qrpass-backend/api/activities?type=event',
      );
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'type': 'event',
        'name': _eventNameController.text.trim(),
        'date': _selectedDate!.toUtc().toIso8601String(),
        'team_a': '',
        'team_b': '',
        'stadium_id': 'STAD_01',
        'match_status': 'upcoming',
      });

      if (_image != null) {
        final ext = _image!.path.split('.').last.toLowerCase();
        final mediaType = (ext == 'png') ? 'png' : 'jpeg';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _image!.path,
            contentType: MediaType('image', mediaType),
          ),
        );
      }

      final response = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 201) {
        final jsonData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event added: ${jsonData['message'] ?? 'Success'}'),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final error = json.decode(responseBody)['message'] ?? 'Server error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error (${response.statusCode})')),
        );
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request timeout')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Event",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    labelText: "Event Name*",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Event Date*",
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? "Select date"
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImagePreview(),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _isPickingImage ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Select Image"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitEvent,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text("Add Event"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return _image != null
        ? Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                if (mounted) {
                  setState(() => _image = null);
                }
              },
            ),
          ],
        )
        : Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                _isPickingImage ? 'Loading image...' : 'No image selected',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
  }
}
