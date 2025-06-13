import 'package:flutter/material.dart';
import 'package:qrpass/page/QRScanpage.dart';
import 'addevint.dart';
import 'Spectator.dart';
import 'package:qrpass/page/Eventlist.dart';
import 'package:qrpass/page/doors.dart';
import 'package:qrpass/page/event_service.dart';
import 'logout.dart';

class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({super.key});

  @override
  State<OrganizerHomePage> createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  // No need to store events locally here, the EventService handles it globally.

  void _addEvent() async {
    final newEvent = await showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEventModal(),
    );

    if (newEvent != null && newEvent is Event) {
      EventService().addEvent(newEvent); // Save globally
      setState(() {}); // Refresh if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 135, 45),
      appBar: AppBar(
        title: const Text("Organizer Home"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        color: const Color.fromARGB(255, 12, 135, 45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue Organizer ',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildOptionCard(
              context,
              icon: Icons.qr_code_scanner,
              label: "Scan qrcode",
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => QRScanPage(),
                  ),
            ),

            const SizedBox(height: 40),
            _buildOptionCard(
              context,
              icon: Icons.door_front_door,
              label: "Manage Doors",
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const DoorsModal(role: 'organizer'),
                  ),
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              icon: Icons.people,
              label: "Manage Spectators",
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const SpectatorModal(),
                  ),
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              icon: Icons.add_circle,
              label: "Add Event",
              onTap: _addEvent,
            ),

            const SizedBox(height: 40),
            _buildOptionCard(
              context,
              icon: Icons.event,
              label: "Event list ",
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const EventListPage(),
                  ),
            ),
            const SizedBox(height: 40),
            _buildOptionCard(
              context,
              icon: Icons.door_front_door,
              label: "LOG OUT ",
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const LogoutPage(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
