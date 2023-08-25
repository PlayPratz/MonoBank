import 'package:monobank/models/player.dart';

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

  Transaction.load({
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.createdAt,
  });

  factory Transaction.fromJson(
          Map<String, dynamic> json, Map<String, Player> players) =>
      Transaction.load(
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
