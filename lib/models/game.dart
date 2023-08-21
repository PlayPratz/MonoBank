import 'package:monobank/elements/monocolors.dart';
import 'package:monobank/models/player.dart';

class Game {
  final String id;

  final int moneyOnGo;
  final int initialBalance;

  final Map<Player, PlayerState> playerStates = {};

  final List<Transaction> transactions = [];

  Game(
      {required this.id,
      required this.moneyOnGo,
      required this.initialBalance});

  void initPlayers(List<Player> players) {
    final colorKeys = playerColors.keys.toList()..shuffle();
    for (final player in players) {
      playerStates[player] = PlayerState(
          balance: initialBalance,
          colorHex: playerColors[colorKeys.first]!.value);

      colorKeys.removeAt(0);
    }
  }

  int get numberOfPlayers => playerStates.length;

  Map<String, dynamic> toJson() => {
        "id": id,
        "moneyOnGo": moneyOnGo,
        "initialBalance": initialBalance,
        "playerStates": playerStates.map(
            (player, playerState) => MapEntry(player.id, playerState.toJson()))
      };
}

class PlayerState {
  int balance;
  bool isBankrupt;

  final int colorHex;

  PlayerState(
      {required this.balance, this.isBankrupt = false, required this.colorHex});

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        balance: json["balance"],
        isBankrupt: json["isBankrupt"] == 1,
        colorHex: json["colorHex"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "isBankrupt": isBankrupt ? 1 : 0,
        "colorHex": colorHex
      };
}

class Transaction {
  final Player? sender;
  final Player? receiver;

  final int amount;

  Transaction(
      {required this.sender, required this.receiver, required this.amount});
}
