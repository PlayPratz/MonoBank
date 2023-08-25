import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monobank/controller/game_room_controller.dart';
import 'package:monobank/elements/monocolors.dart';
import 'package:monobank/models/game.dart';
import 'package:monobank/models/player.dart';
import 'package:monobank/models/transaction.dart';

late GameRoomController _gameRoomController;

class GameRoom extends StatelessWidget {
  final Game game;

  GameRoom({super.key, required this.game}) {
    _gameRoomController = GameRoomController(game: game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("${game.playerCount} Players")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(flex: 2, child: _TransactionLog(game: game)),
              const SizedBox(height: 8),
              Expanded(child: _PlayerBlobPane(game: game)),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }
}

class _PlayerBlobPane extends StatelessWidget {
  final Game game;

  const _PlayerBlobPane({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final playerStatesEntries = game.playerStates.entries.toList();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < game.playerCount) {
          final playerStateEntry = playerStatesEntries[index];
          return _PlayerChip(
              game: game,
              player: playerStateEntry.key,
              color: Color(
                playerStateEntry.value.colorValue,
              ));
        } else {
          return _PlayerChip(
            game: game,
            player: bank,
            color: bankColor,
          );
        }
      },
      itemCount: game.playerCount + 1,
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final Game game;

  final Player player;
  final Color color;

  const _PlayerChip(
      {super.key,
      required this.game,
      required this.player,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return DragTarget<Player>(
      onWillAccept: (incomingPlayer) {
        if (incomingPlayer == null) {
          print("Check"); //TODO
          return false;
        }
        return incomingPlayer != player;
      },
      onAccept: (incomingPlayer) {
        _handleTransaction(context, incomingPlayer, player);
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<Player>(
            data: player,
            feedback: _PlayerBlob(
              player: player,
              color: color,
              size: 64,
            ),
            child: _PlayerBlob(
              player: player,
              color: color,
              size: 64,
            ));
      },
    );
  }

  _handleTransaction(
      BuildContext context, Player sender, Player receiver) async {
    print("${sender.name} @ ${receiver.name}"); //TODO log

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => _AddTransaction(
        game: game,
        sender: sender,
        receiver: receiver,
      ),
    );
  }
}

class _PlayerBlob extends StatelessWidget {
  final Player player;
  final Color color;

  final double size;

  const _PlayerBlob(
      {super.key, required this.player, required this.color, this.size = 128});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      foregroundColor: Colors.white,
      radius: size,
      child: size >= 64
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
                Text(
                  player == bank
                      ? "∞"
                      : _gameRoomController.game.playerStates[player]!.balance
                          .toString(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                      ),
                )
              ],
            )
          : Text(player == bank ? "₹" : player.name.characters.first),
    );
  }
}

class _TransactionLog extends StatelessWidget {
  final Game game;

  const _TransactionLog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<GameRoomState>(
                    stream: _gameRoomController.gameRoomStateStream,
                    builder: (context, snapshot) {
                      final reversedTransactions =
                          game.transactions.reversed.toList(growable: false);
                      return ListView.separated(
                        itemCount: game.transactions.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final transaction = reversedTransactions[index];
                          final senderState =
                              game.playerStates[transaction.sender];
                          final receiverState =
                              game.playerStates[transaction.receiver];
                          final formattedTime =
                              DateFormat.Hm().format(transaction.createdAt);
                          return ListTile(
                            leading: Text(
                              formattedTime,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _PlayerBlob(
                                  player: transaction.sender,
                                  color: transaction.sender == bank
                                      ? bankColor
                                      : Color(senderState!.colorValue),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 64,
                                  child: Center(
                                    child: Text(
                                      transaction.amount.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                _PlayerBlob(
                                    player: transaction.receiver,
                                    color: transaction.receiver == bank
                                        ? bankColor
                                        : Color(receiverState!.colorValue),
                                    size: 14),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(height: 0, color: Colors.grey);
                        },
                      );
                    }),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {},
                label: Text("TRANSACTION LOG",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                        )),
                icon: const Icon(Icons.history),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTransaction extends StatelessWidget {
  final Player sender;
  final Player receiver;

  final Game game;

  _AddTransaction({
    super.key,
    required this.game,
    required this.sender,
    required this.receiver,
  });

  final _formKey = GlobalKey<FormState>();

  // final _amountFocusNode = FocusNode();
  final _amountTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // _amountFocusNode.requestFocus();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PlayerBlob(
                      size: 64,
                      player: sender,
                      color: sender == bank
                          ? bankColor
                          : Color(game.playerStates[sender]!.colorValue)),
                  const Icon(Icons.send),
                  _PlayerBlob(
                      size: 64,
                      player: receiver,
                      color: receiver == bank
                          ? bankColor
                          : Color(game.playerStates[receiver]!.colorValue)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountTextController,
                decoration:
                    const InputDecoration(labelText: "Amount to Transfer"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.parse(value) < 0) {
                    return "Please enter a non-negative number";
                  }
                  return null;
                },
                // focusNode: _amountFocusNode,
                // textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              FilledButtonTheme(
                data: FilledButtonThemeData(
                    style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                )),
                child: Wrap(
                  spacing: 2,
                  children:
                      ["50", "100", "150", "200", "250", "500", "1000", "2000"]
                          .map((amount) => FilledButton(
                              onPressed: () {
                                _amountTextController.text = amount;
                              },
                              child: Text(amount)))
                          .toList(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () => _handleTransactionSubmit(context),
                  child: const Text("Add Transaction"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _handleTransactionSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountTextController.text);
      final transaction =
          Transaction(sender: sender, receiver: receiver, amount: amount);
      _gameRoomController.addTransaction(transaction);
      Navigator.pop(context);
    }
  }
}
