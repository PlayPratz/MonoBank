import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monobank/elements/loading_indicator.dart';
import 'package:monobank/screens/game_room/game_room.dart';
import 'package:monobank/services/db_service.dart';

class GameList extends StatelessWidget {
  const GameList({super.key});

  @override
  Widget build(BuildContext context) {
    final games = GetIt.instance.get<DbService>().getGames();
    return FutureBuilder(
      future: games,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final games = snapshot.data!;
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(games[index].modifiedAt.toString()),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GameRoom(game: games[index]))),
            ),
            itemCount: games.length,
          );
        } else {
          return const LoadingIndicator();
        }
      },
    );
  }
}
