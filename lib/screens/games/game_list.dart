import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monobank/services/InheritedServices.dart';

class GameList extends StatelessWidget {
  const GameList({super.key});

  @override
  Widget build(BuildContext context) {
    final games = InheritedServices.of(context).dbService.getGames();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(),
      itemCount: games.length,
    );
  }
}
