import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ValueNotifier(0);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mono Bank"),
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedIndex,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (int),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: "Games"),
          NavigationDestination(icon: Icon(Icons.people), label: "Players"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
