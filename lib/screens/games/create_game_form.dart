import 'package:flutter/material.dart';
import 'package:monobank/models/player.dart';
import 'package:monobank/services/InheritedServices.dart';

class CreateGameForm extends StatelessWidget {
  CreateGameForm({super.key});

  final _formKey = GlobalKey<FormState>();

  final _initialBalanceController = TextEditingController();
  final _moneyOnGoController = TextEditingController();

  final _moneyOnGoFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final players = InheritedServices.of(context).dbService.getPlayers();
    players.sort((a, b) => a.name.compareTo(b.name));

    final selectedPlayers = <Player>[];

    _initialBalanceController.text = "1500";
    _moneyOnGoController.text = "200";

    return Scaffold(
      appBar: AppBar(title: const Text("Create Game")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Select Players"),
              const SizedBox(height: 4),
              PlayerSelectionPane(
                players: players,
                selectedPlayers: selectedPlayers,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialBalanceController,
                decoration: const InputDecoration(labelText: "Initial Balance"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.parse(value) < 0) {
                    return "Please enter a non-negative number";
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _moneyOnGoFocusNode.requestFocus(),
              ),
              const SizedBox(height: 8),
              FilledButtonTheme(
                data: FilledButtonThemeData(
                    style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                )),
                child: Wrap(
                  spacing: 2,
                  children: ["1000", "1500", "2000", "2500", "5000"]
                      .map((amount) => FilledButton(
                          onPressed: () {
                            _initialBalanceController.text = amount;
                          },
                          child: Text(amount)))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _moneyOnGoController,
                focusNode: _moneyOnGoFocusNode,
                decoration: const InputDecoration(
                    labelText: "Money Earned on Passing Go"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.parse(value) < 0) {
                    return "Please enter a non-negative number";
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              FilledButtonTheme(
                data: FilledButtonThemeData(
                    style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                )),
                child: Wrap(
                  spacing: 2,
                  children: ["100", "150", "200", "250", "500"]
                      .map((amount) => FilledButton(
                          onPressed: () {
                            _initialBalanceController.text = amount;
                          },
                          child: Text(amount)))
                      .toList(),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: FilledButton(
                  // style: FilledButton.styleFrom(
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        selectedPlayers.length >= 2) {
                    } else if (selectedPlayers.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(left: 8, right: 8, bottom: 16),
                          content:
                              Text("Please select a minimum of two players!"),
                          showCloseIcon: true,
                          dismissDirection: DismissDirection.horizontal,
                        ),
                      );
                    }
                  },
                  child: const Text("Start"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerSelectionPane extends StatefulWidget {
  final List<Player> players;
  final List<Player> selectedPlayers;
  const PlayerSelectionPane(
      {super.key, required this.players, required this.selectedPlayers});

  @override
  State<PlayerSelectionPane> createState() => _PlayerSelectionPaneState();
}

class _PlayerSelectionPaneState extends State<PlayerSelectionPane> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Wrap(
          direction: Axis.horizontal,
          spacing: 8,
          children: widget.players
              .map((player) => ChoiceChip(
                    label: Text(player.name),
                    selected: widget.selectedPlayers.contains(player),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          if (widget.selectedPlayers.length == 6) {
                            // TODO Max Players

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                    left: 8, right: 8, bottom: 16),
                                content: Text(
                                    "A maximum of six players can play a game!"),
                                showCloseIcon: true,
                                dismissDirection: DismissDirection.horizontal,
                              ),
                            );
                          } else {
                            widget.selectedPlayers.add(player);
                          }
                        } else {
                          widget.selectedPlayers.remove(player);
                        }
                      });
                    },
                  ))
              .toList(),
        )
      ],
    );
  }
}
