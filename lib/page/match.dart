import 'package:flutter/material.dart';
import 'match_service.dart'; // import your service file
import 'package:provider/provider.dart';

class MatchPage extends StatelessWidget {
  const MatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matchService = Provider.of<MatchService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: FutureBuilder(
        future: matchService.fetchMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While fetching data
            return const Center(child: CircularProgressIndicator());
          } else {
            if (matchService.matches.isEmpty) {
              return const Center(child: Text('No matches found.'));
            } else {
              return ListView.builder(
                itemCount: matchService.matches.length,
                itemBuilder: (context, index) {
                  final match = matchService.matches[index];
                  return ListTile(
                    leading:
                        match.imageUrl.isNotEmpty
                            ? Image.network(
                              match.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.sports_soccer),
                    title: Text(match.name),
                    subtitle: Text(
                      '${match.date.toLocal()}'.split(' ')[0], // just date part
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
