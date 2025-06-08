import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpectatorModal extends StatefulWidget {
  const SpectatorModal({Key? key}) : super(key: key);

  @override
  State<SpectatorModal> createState() => _SpectatorModalState();
}

class _SpectatorModalState extends State<SpectatorModal> {
  List<Map<String, String>> allSpectators = [];
  List<Map<String, String>> filteredSpectators = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSpectators();
  }

  Future<void> fetchSpectators() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.8.22:8080/qrpass-backend/api/users?role=spectateur",
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          allSpectators =
              decoded.map<Map<String, String>>((item) {
                if (item is Map<String, dynamic>) {
                  return {
                    "name": item['username']?.toString() ?? 'Unknown',
                    "email": item['email']?.toString() ?? 'unknown@email.com',
                  };
                } else {
                  return {"name": "Invalid", "email": "Invalid"};
                }
              }).toList();

          setState(() {
            filteredSpectators = allSpectators;
            _isLoading = false;
          });
        } else {
          throw Exception("Expected a list, but got: ${decoded.runtimeType}");
        }
      } else {
        throw Exception('Failed to load spectators: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _filterSpectators(String query) {
    final filtered =
        allSpectators.where((spectator) {
          final name = spectator['name']?.toLowerCase() ?? '';
          final email = spectator['email']?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList();

    setState(() {
      filteredSpectators = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manage Spectators",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search spectator by name or email",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _filterSpectators,
          ),
          const SizedBox(height: 15),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child:
                    filteredSpectators.isEmpty
                        ? const Center(child: Text("No spectators found."))
                        : ListView.builder(
                          itemCount: filteredSpectators.length,
                          itemBuilder: (context, index) {
                            final spectator = filteredSpectators[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(spectator["name"] ?? 'No Name'),
                                subtitle: Text(
                                  spectator["email"] ?? 'No Email',
                                ),
                              ),
                            );
                          },
                        ),
              ),
        ],
      ),
    );
  }
}
