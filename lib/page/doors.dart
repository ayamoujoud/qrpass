import 'package:flutter/material.dart';
import 'shared_door_data.dart';

class DoorsModal extends StatefulWidget {
  final String role; // 'organizer' or 'spectator'

  const DoorsModal({super.key, required this.role});

  @override
  State<DoorsModal> createState() => _DoorsModalState();
}

class _DoorsModalState extends State<DoorsModal> {
  final List<Map<String, String>> doors = SharedDoorData().doors;

  void _toggleDoorStatus(int index) {
    setState(() {
      doors[index]["status"] =
          doors[index]["status"] == "Available" ? "Occupied" : "Available";
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder:
          (_, controller) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              controller: controller,
              itemCount: doors.length,
              itemBuilder: (context, index) {
                final door = doors[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(door["door"]!),
                    subtitle: Text("Status: ${door["status"]!}"),
                    trailing:
                        widget.role == 'organizer'
                            ? IconButton(
                              icon: Icon(
                                door["status"] == "Available"
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color:
                                    door["status"] == "Available"
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              onPressed: () => _toggleDoorStatus(index),
                            )
                            : Icon(
                              door["status"] == "Available"
                                  ? Icons.lock_open
                                  : Icons.lock,
                              color:
                                  door["status"] == "Available"
                                      ? Colors.green
                                      : Colors.red,
                            ),
                  ),
                );
              },
            ),
          ),
    );
  }
}
