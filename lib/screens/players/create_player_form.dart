import 'package:flutter/material.dart';
import 'package:monobank/models/player.dart';
import 'package:monobank/services/InheritedServices.dart';
import 'package:monobank/util/util.dart';

class CreatePlayerForm extends StatelessWidget {
  CreatePlayerForm({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String playerName = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Player"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a valid name";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (value) => playerName = value,
                textCapitalization: TextCapitalization.words,
              ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final player =
                            Player(id: getUniqueId(), name: playerName.trim());
                        InheritedServices.of(context)
                            .dbService
                            .addPlayer(player);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Create")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
