import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (m) => ref.read(themeModeProvider.notifier).state = m ?? ThemeMode.system,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => ref.read(authServiceProvider).signOut(),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Support'),
            onTap: () => launchUrl(Uri.parse('https://support.example.com')),
          ),
        ],
      ),
    );
  }
}