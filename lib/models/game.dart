import 'dart:collection';

import 'package:monobank/elements/monocolors.dart';
import 'package:monobank/models/player.dart';
import 'package:monobank/models/transaction.dart';

class Game {
  final String id;

  /// The bank-balance that each player begins with
  final int initialBalance;

  /// The money received by a player for landing on or passing Go.
  final int moneyOnGo;

  /// Timestamp of creation
  final DateTime createdAt;

  /// Timestamp of last modification
  DateTime _modifiedAt;
  DateTime get modifiedAt => _modifiedAt;

  /// A list of players playing this game
  final List<Player> _players;
  UnmodifiableListView<Player> get players => UnmodifiableListView(_players);
  int get playerCount => players.length;

  /// A map of every [Player] and their respective [PlayerState]
  final Map<Player, PlayerState> _playerStates;
  Map<Player, PlayerState> get playerStates => _playerStates;

  /// A list of transactions that have taken place during the game
  final List<Transaction> _transactions;
  List<Transaction> get transactions => _transactions;

  Game({
    required this.id,
    required this.initialBalance,
    required this.moneyOnGo,
    required List<Player> players,
  })  : createdAt = DateTime.now(),
        _modifiedAt = DateTime.now(),
        _players = players,
        _playerStates = {},
        _transactions = [] {
    _initPlayers();
  }
  //
  // Game.load({
  //   required this.id,
  //   required this.initialBalance,
  //   required this.moneyOnGo,
  //   required this.createdAt,
  //   required DateTime modifiedAt,
  //   required
  //   required Map<Player, PlayerState> playerStates,
  //   required List<Transaction> transactions,
  // })  : _modifiedAt = modifiedAt,
  //       _playerStates = playerStates,
  //       _transactions = transactions;

  Game.lazyLoad(
      {required this.id,
      required this.initialBalance,
      required this.moneyOnGo,
      required this.createdAt,
      required DateTime modifiedAt,
      required List<Player> players})
      : _modifiedAt = modifiedAt,
        _players = players,
        _playerStates = {},
        _transactions = [];

  // factory Game.fromJson(
  //   Map<String, dynamic> json,
  //   Map<String, Player> players,
  //   Map<String, Transaction> transactions,
  // ) =>
  //     Game.load(
  //         id: json["id"],
  //         initialBalance: json["initialBalance"],
  //         moneyOnGo: json["moneyOnGo"],
  //         createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
  //         modifiedAt: DateTime.fromMillisecondsSinceEpoch(json["modifiedAt"]),
  //         playerStates: (json["playerStates"]
  //                 as Map<String, Map<String, dynamic>>)
  //             .map((playerId, playerStateJson) => MapEntry(
  //                 players[playerId]!, PlayerState.fromJson(playerStateJson))),
  //         transactions: (json["transactions"] as List<Map<String, dynamic>>)
  //             .map((transactionJson) =>
  //                 Transaction.fromJson(transactionJson, players))
  //             .toList());
  //
  // Map<String, dynamic> toJson() => {
  //       "id": id,
  //       "initialBalance": initialBalance,
  //       "moneyOnGo": moneyOnGo,
  //       "createdAt": createdAt.millisecondsSinceEpoch,
  //       "modifiedAt": modifiedAt.millisecondsSinceEpoch,
  //       "playerStates": playerStates.map(
  //           (player, playerState) => MapEntry(player.id, playerState.toJson())),
  //       "transactions": _transactions.map((transaction) => transaction.toJson())
  //     };

  void _initPlayers() {
    final colorKeys = playerColors.keys.toList()..shuffle();
    for (final player in players) {
      playerStates[player] = PlayerState(
          balance: initialBalance,
          colorValue: playerColors[colorKeys.first]!.value);
      colorKeys.removeAt(0);
    }
  }

  void lazyLoad(
      Map<Player, PlayerState> playerStates, List<Transaction> transactions) {
    _playerStates.addAll(playerStates);
    transactions.addAll(transactions);
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _updatePlayerBalance(transaction.sender, -transaction.amount);
    _updatePlayerBalance(transaction.receiver, transaction.amount);
    _modifiedAt = DateTime.now();
  }

  void _updatePlayerBalance(Player player, int amount) {
    if (player == bank) {
      return;
    }
    playerStates[player]!.balance += amount;
  }
}

/// Describes the state of a player in the game
class PlayerState {
  /// The bank balance of the player
  int balance;

  /// Whether the player is bankrupt
  // TODO or has quit?
  bool isBankrupt;

  /// The color associated with the player
  // TODO add shapes?
  final int colorValue;

  PlayerState(
      {required this.balance,
      this.isBankrupt = false,
      required this.colorValue});

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        balance: json["balance"],
        isBankrupt: json["isBankrupt"] == 1,
        colorValue: json["colorValue"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance.toString(),
        "isBankrupt": isBankrupt ? 1 : 0,
        "colorValue": colorValue
      };
}
