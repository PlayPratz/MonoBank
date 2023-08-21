import 'package:flutter/material.dart';

class CreateGameForm extends StatelessWidget {
  CreateGameForm({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Game")),
      body: Form(
          key: _formKey,
          child: Column(
            children: [],
          )),
    );
  }
}
