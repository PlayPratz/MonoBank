import 'package:flutter/material.dart';
import 'package:monobank/screens/games/game_list.dart';
import 'package:monobank/screens/players/player_list.dart';
import 'package:monobank/screens/settings/settings.dart';

class Home extends StatelessWidget {
  final int initialIndex;
  const Home({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ValueNotifier(initialIndex);
    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (context, index, child) => Scaffold(
          appBar: AppBar(
            title: const Text("Mono Bank"),
          ),
          body: _screens[index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (newIndex) => selectedIndex.value = newIndex,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.list_alt), label: "Games"),
              NavigationDestination(icon: Icon(Icons.people), label: "Players"),
              NavigationDestination(
                  icon: Icon(Icons.settings), label: "Settings"),
            ],
          ),
          floatingActionButton: index == 0
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/games/create");
                  },
                  child: const Icon(Icons.play_arrow),
                )
              : index == 1
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/players/create");
                      },
                      child: const Icon(Icons.add),
                    )
                  : null),
    );
  }
}

const _screens = <Widget>[GameList(), PlayerList(), SettingsScreen()];
