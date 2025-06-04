import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'addevint.dart';
import 'event_service.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventService>(context).events;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                () =>
                    Provider.of<EventService>(
                      context,
                      listen: false,
                    ).clearEvents(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const AddEventModal(),
            ),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body:
          events.isEmpty
              ? const Center(child: Text("No events available"))
              : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading:
                          event.imageUrl.isNotEmpty
                              ? Image.network(
                                event.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                              )
                              : const Icon(Icons.event),
                      title: Text(event.name),
                      subtitle: Text("${event.date.toLocal()}".split(' ')[0]),
                    ),
                  );
                },
              ),
    );
  }
}
