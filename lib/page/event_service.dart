import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Event Model
class Event {
  final String name;
  final DateTime date;
  final String imageUrl;

  const Event({required this.name, required this.date, required this.imageUrl});

  factory Event.fromJson(Map<String, dynamic> json) {
    // Fix date format: remove double spaces
    String rawDate = (json['date'] ?? '').replaceAll('  ', ' ');
    DateTime parsedDate = DateTime.tryParse(rawDate) ?? DateTime(2000, 1, 1);

    return Event(
      name: json['name'] ?? 'No name',
      date: parsedDate,
      imageUrl: json['photo_url'] ?? '',
    );
  }

  @override
  String toString() => 'Event(name: $name, date: $date, imageUrl: $imageUrl)';
}

// Event Service with ChangeNotifier for state management
class EventService with ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event newEvent) {
    _events.add(newEvent);
    notifyListeners();
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }

  Future<void> fetchEvents() async {
    const String url =
        'http://192.168.8.22:8080/qrpass-backend/api/activities?type=event';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _events.clear();
        _events.addAll(jsonData.map((e) => Event.fromJson(e)).toList());
        notifyListeners();
      } else {
        print("Failed to load events. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }
}
