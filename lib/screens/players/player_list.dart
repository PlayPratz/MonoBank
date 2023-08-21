import 'package:flutter/material.dart';
import 'package:monobank/services/InheritedServices.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final players = InheritedServices.of(context).dbService.getPlayers();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(players[index].name.toUpperCase()),
        trailing: const Icon(Icons.chevron_right),
      ),
      itemCount: players.length,
    );
  }
}
