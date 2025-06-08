import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Match Model
class Match {
  final String name;
  final DateTime date;
  final String imageUrl;
  final String teamA;
  final String teamB;
  final String activityId;
  final String stadiumId;
  final String matchStatus;

  const Match({
    required this.name,
    required this.date,
    required this.imageUrl,
    required this.teamA,
    required this.teamB,
    required this.activityId,
    required this.stadiumId,
    required this.matchStatus,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    String fixedDate = (json['date'] ?? '').replaceAll('  ', ' ');
    return Match(
      name: json['name'] ?? 'Unknown Match',
      date: DateTime.tryParse(fixedDate) ?? DateTime(2000, 1, 1),
      imageUrl: json['photo_url'] ?? '',
      teamA: (json['team_a'] ?? '').trim(),
      teamB: (json['team_b'] ?? '').trim(),
      activityId: json['activity_id'] ?? '',
      stadiumId: json['stadium_id'] ?? '',
      matchStatus: json['match_status'] ?? '',
    );
  }
}

// Match Service
class MatchService with ChangeNotifier {
  final List<Match> _matches = [];

  List<Match> get matches => List.unmodifiable(_matches);

  Future<void> fetchMatches() async {
    const url =
        'http://192.168.8.22:8080/qrpass-backend/api/activities?type=match';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _matches
          ..clear()
          ..addAll(data.map((json) => Match.fromJson(json)));
        notifyListeners();
      } else {
        print('Failed to load matches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }
}

// Helper function to check valid network image URLs
bool isValidNetworkUrl(String url) {
  if (url.isEmpty) return false;
  Uri? uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}

// Main widget displaying the matches list
class MatchesPage extends StatefulWidget {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final MatchService _matchService = MatchService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    await _matchService.fetchMatches();
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildMatchTile(Match match) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading:
            isValidNetworkUrl(match.imageUrl)
                ? Image.network(
                  match.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.sports_soccer, size: 50),
                )
                : const Icon(Icons.sports_soccer, size: 50),
        title: Text(match.name),
        subtitle: Text(
          '${match.teamA} vs ${match.teamB}\n'
          '${match.date.toLocal()}',
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matchService.matches;

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : matches.isEmpty
              ? const Center(child: Text('No matches found'))
              : ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return _buildMatchTile(match);
                },
              ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MatchesPage()));
}
