import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [SwitchSetting()],
    );
  }
}

class SwitchSetting extends StatefulWidget {
  const SwitchSetting({super.key});

  @override
  State<SwitchSetting> createState() => _SwitchSettingState();
}

class _SwitchSettingState extends State<SwitchSetting> {
  bool value = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Dummy Switch"),
      subtitle: const Text("This does literally nothing"),
      onTap: _toggleValue,
      trailing: Switch(onChanged: (_) => _toggleValue(), value: value),
    );
  }

  void _toggleValue() {
    setState(() {
      value = !value;
    });
  }
}
