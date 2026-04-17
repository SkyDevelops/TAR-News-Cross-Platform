import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/providers/news_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const TarNewsLogo(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/home/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: AppTheme.primary)),
        error: (_, __) =>
            const Center(child: Text('Gagal memuat profil')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                // FIXED: withOpacity(0.15) → .withValues(alpha: 0.15)
                backgroundColor:
                    AppTheme.primary.withValues(alpha: 0.15),
                backgroundImage: (profile?.avatarUrl != null &&
                        profile!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: (profile?.avatarUrl == null ||
                        profile!.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person,
                        size: 48, color: AppTheme.primary)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                profile?.fullName ?? user?.email ?? 'Pengguna',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(user?.email ?? '',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 14)),
              if (profile?.bio != null &&
                  profile!.bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(profile.bio!,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () =>
                    _showEditDialog(context, ref, profile),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              _ProfileMenuItem(
                icon: Icons.bookmark_outline,
                label: 'Bookmark Saya',
                onTap: () => context.go('/home/bookmark'),
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                label: 'Pengaturan',
                onTap: () => context.go('/home/settings'),
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline,
                label: 'Tentang Kami',
                onTap: () => context.go('/home/about'),
              ),
              const Divider(),
              _ProfileMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                color: Colors.red,
                onTap: () async {
                  await ref
                      .read(authProvider.notifier)
                      .logout();
                  if (context.mounted) context.go('/register');
                },
              ),
              const SizedBox(height: 24),
              Text('© 2025 TAR News. All Rights Reserved.',
                  style: TextStyle(
                      color: Colors.grey[400], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, profile) {
    final nameCtrl =
        TextEditingController(text: profile?.fullName ?? '');
    final usernameCtrl =
        TextEditingController(text: profile?.username ?? '');
    final bioCtrl =
        TextEditingController(text: profile?.bio ?? '');
    final avatarCtrl =
        TextEditingController(text: profile?.avatarUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Lengkap')),
              const SizedBox(height: 12),
              TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Username')),
              const SizedBox(height: 12),
              TextField(
                  controller: bioCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Bio'),
                  maxLines: 2),
              const SizedBox(height: 12),
              TextField(
                  controller: avatarCtrl,
                  decoration: const InputDecoration(
                      labelText: 'URL Foto Profil')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              await updateProfile({
                'full_name': nameCtrl.text.trim(),
                'username': usernameCtrl.text.trim(),
                'bio': bioCtrl.text.trim(),
                'avatar_url': avatarCtrl.text.trim(),
              });
              // FIXED: use ref.invalidate() instead of ref.refresh()
              // to avoid unused_result warning
              ref.invalidate(profileProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label,
          style:
              TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right,
          color: Colors.grey[400], size: 20),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    );
  }
}