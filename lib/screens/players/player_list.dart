import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monobank/elements/loading_indicator.dart';
import 'package:monobank/models/player.dart';
import 'package:monobank/services/db_service.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final futurePlayers = GetIt.I.get<DbService>().getPlayers();
    return FutureBuilder<List<Player>>(
      future: futurePlayers,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final players = snapshot.data!;
          return ListView.separated(
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(players[index].name),
              // trailing: const Icon(Icons.chevron_right),
            ),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: players.length,
            reverse: false,
            padding: const EdgeInsets.only(bottom: 72),
          );
        } else {
          return const LoadingIndicator();
        }
      },
    );
  }
}
