import 'dart:collection';

import 'package:monobank/elements/monocolors.dart';
import 'package:monobank/models/player.dart';

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

  /// A map of every [Player] and their respective [PlayerState]
  final Map<Player, PlayerState> _playerStates;
  Map<Player, PlayerState> get playerStates => _playerStates;

  int get playerCount => playerStates.length;
  UnmodifiableListView<Player> get players =>
      UnmodifiableListView(playerStates.keys);

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
        _playerStates = {},
        _transactions = [] {
    _initPlayers(players);
  }

  Game._load({
    required this.id,
    required this.initialBalance,
    required this.moneyOnGo,
    required this.createdAt,
    required DateTime modifiedAt,
    required Map<Player, PlayerState> playerStates,
    required List<Transaction> transactions,
  })  : _modifiedAt = modifiedAt,
        _playerStates = playerStates,
        _transactions = transactions;

  factory Game.fromJson(Map<String, dynamic> json, Map<String, Player> players,
          Map<String, Transaction> transactions) =>
      Game._load(
          id: json["id"],
          initialBalance: json["initialBalance"],
          moneyOnGo: json["moneyOnGo"],
          createdAt: DateTime.fromMillisecondsSinceEpoch(json["createdAt"]),
          modifiedAt: DateTime.fromMillisecondsSinceEpoch(json["modifiedAt"]),
          playerStates: (json["playerStates"]
                  as Map<String, Map<String, dynamic>>)
              .map((playerId, playerStateJson) => MapEntry(
                  players[playerId]!, PlayerState.fromJson(playerStateJson))),
          transactions: (json["transactions"] as List<Map<String, dynamic>>)
              .map((transactionJson) =>
                  Transaction.fromJson(transactionJson, players))
              .toList());

  Map<String, dynamic> toJson() => {
        "id": id,
        "initialBalance": initialBalance,
        "moneyOnGo": moneyOnGo,
        "createdAt": createdAt.millisecondsSinceEpoch,
        "modifiedAt": modifiedAt.millisecondsSinceEpoch,
        "playerStates": playerStates.map(
            (player, playerState) => MapEntry(player.id, playerState.toJson())),
        "transactions": _transactions.map((transaction) => transaction.toJson())
      };

  void _initPlayers(List<Player> players) {
    final colorKeys = playerColors.keys.toList()..shuffle();
    for (final player in players) {
      playerStates[player] = PlayerState(
          balance: initialBalance,
          colorHex: playerColors[colorKeys.first]!.value);
      colorKeys.removeAt(0);
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _modifiedAt = DateTime.now();
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
  final int colorHex;

  PlayerState(
      {required this.balance, this.isBankrupt = false, required this.colorHex});

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        balance: json["balance"],
        isBankrupt: json["isBankrupt"] == 1,
        colorHex: json["colorHex"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance.toString(),
        "isBankrupt": isBankrupt ? 1 : 0,
        "colorHex": colorHex
      };
}

/// A transaction between two players or a player and the bank
class Transaction {
  /// The player that was the sender or "giver"
  final Player sender;

  /// The player that was the receiver or "taker".
  final Player receiver;

  /// The amount of money dealt
  final int amount;

  /// Timestamp at which the transaction was created
  final DateTime createdAt;

  Transaction(
      {required this.sender, required this.receiver, required this.amount})
      : createdAt = DateTime.now();

  Transaction._load({
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.createdAt,
  });

  factory Transaction.fromJson(
          Map<String, dynamic> json, Map<String, Player> players) =>
      Transaction._load(
          sender: players[json["sender"]] ?? bank,
          receiver: players[json["receiver"]] ?? bank,
          amount: json["amount"],
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            json["createdAt"],
          ));

  Map<String, dynamic> toJson() => {
        "sender": sender.name,
        "receiver": sender.name,
        "amount": amount,
        "createdAt": createdAt.millisecondsSinceEpoch,
      };
}
