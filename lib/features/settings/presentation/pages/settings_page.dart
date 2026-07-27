import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Tema'),
            subtitle: Text('Acompanha o sistema'),
          ),
          Divider(),
          _Attribution(),
        ],
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Créditos', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'Dados do dicionário: CC-CEDICT, distribuído sob a licença '
            'Creative Commons Attribution-ShareAlike (CC BY-SA).',
          ),
          SizedBox(height: 8),
          Text('Áudio de pronúncia: Youdao Dictionary.'),
          SizedBox(height: 8),
          Text('Traduções: Google Cloud Translation.'),
        ],
      ),
    );
  }
}
