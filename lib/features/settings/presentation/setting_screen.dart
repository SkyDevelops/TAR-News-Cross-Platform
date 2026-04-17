import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final isDark = themeNotifier.isDark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/profile'),
        ),
        title: const Text('Pengaturan',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: ListView(
        children: [
          const _SectionHeader('Tampilan'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
                isDark ? 'Mode gelap aktif' : 'Mode terang aktif',
                style: const TextStyle(fontSize: 12)),
            value: isDark,
            // FIXED: activeColor → activeThumbColor
            activeThumbColor: AppTheme.primary,
            onChanged: (_) =>
                ref.read(themeModeProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          const _SectionHeader('Notifikasi'),
          SwitchListTile(
            secondary:
                const Icon(Icons.notifications_outlined),
            title: const Text('Notifikasi Berita',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Terima notifikasi berita terbaru',
                style: TextStyle(fontSize: 12)),
            value: false,
            // FIXED: activeColor → activeThumbColor
            activeThumbColor: AppTheme.primary,
            onChanged: (_) {},
          ),
          const Divider(height: 1),
          const _SectionHeader('Tentang'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Kami',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey),
            onTap: () => context.go('/home/about'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Kebijakan Privasi',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Syarat & Ketentuan',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Kirim Feedback',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('TAR News v1.0.0',
                style: TextStyle(
                    color: Colors.grey[400], fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
                '© 2025 TAR News. All Rights Reserved.',
                style: TextStyle(
                    color: Colors.grey[400], fontSize: 12)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}