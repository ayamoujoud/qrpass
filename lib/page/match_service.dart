import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Match {
  final String name;
  final DateTime date;
  final String imageUrl;

  const Match({required this.name, required this.date, required this.imageUrl});

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      name: json['name'] ?? 'Unknown Match',
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class MatchService with ChangeNotifier {
  final List<Match> _matches = [];

  List<Match> get matches => _matches;

  Future<void> fetchMatches() async {
    const url =
        'http://192.168.1.118:8080/qrpass-backend/api/activities?type=match';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _matches.clear();
        _matches.addAll(data.map((json) => Match.fromJson(json)).toList());
        notifyListeners();
      } else {
        print('Failed to load matches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }
}
