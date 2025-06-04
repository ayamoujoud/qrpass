import 'package:flutter/material.dart';

class Event {
  final String name;
  final DateTime date;
  final String imageUrl;

  const Event({required this.name, required this.date, required this.imageUrl});

  @override
  String toString() => 'Event(name: $name, date: $date, imageUrl: $imageUrl)';
}

class EventService with ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event newEvent) {
    _events.add(newEvent);
    notifyListeners();
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }
}
