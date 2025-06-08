import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match_service.dart'; // Your MatchService file

class MatchPage extends StatelessWidget {
  const MatchPage({super.key});

  // Helper to validate image URL
  bool _isValidNetworkUrl(String url) {
    if (url.isEmpty) return false;
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  @override
  Widget build(BuildContext context) {
    final matchService = Provider.of<MatchService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      backgroundColor: const Color(0xFFF2F2F2), // light gray background
      body: FutureBuilder(
        future: matchService.fetchMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (matchService.matches.isEmpty) {
              return const Center(child: Text('No matches found.'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: matchService.matches.length,
                itemBuilder: (context, index) {
                  final match = matchService.matches[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            _isValidNetworkUrl(match.imageUrl)
                                ? Image.network(
                                  match.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.sports_soccer,
                                      size: 40,
                                    );
                                  },
                                )
                                : const Icon(Icons.sports_soccer, size: 40),
                      ),
                      title: Text(
                        match.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${match.date.toLocal()}'.split(' ')[0],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
