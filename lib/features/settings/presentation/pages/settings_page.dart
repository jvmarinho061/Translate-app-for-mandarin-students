import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/features/settings/domain/entities/app_theme_mode.dart';
import 'package:pinyinapp/features/settings/presentation/cubit/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: const [
          _ThemeSelector(),
          Divider(),
          _Attribution(),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, mode) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.brightness_6),
                const SizedBox(width: 16),
                Text('Tema', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: AppThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Sistema'),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Claro'),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Escuro'),
                  ),
                ],
                selected: {mode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    context.read<ThemeCubit>().select(selection.first),
              ),
            ),
          ],
        ),
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
