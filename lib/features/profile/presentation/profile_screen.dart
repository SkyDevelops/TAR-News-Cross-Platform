// lib/features/profile/presentation/profile_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (_, __) =>
            const Center(child: Text('Gagal memuat profil')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 52,
                backgroundColor:
                    AppTheme.primary.withValues(alpha: 0.15),
                backgroundImage: (profile?.avatarUrl != null &&
                        profile!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(profile.avatarUrl!) as ImageProvider
                    : null,
                child: (profile?.avatarUrl == null ||
                        profile!.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person,
                        size: 52, color: AppTheme.primary)
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
              if (profile?.username != null &&
                  profile!.username!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('@${profile.username!}',
                    style: TextStyle(
                        color: AppTheme.primary.withValues(alpha: 0.8),
                        fontSize: 13)),
              ],
              if (profile?.bio != null &&
                  profile!.bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(profile.bio!,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showEditSheet(context, ref, profile),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
                  await ref.read(authProvider.notifier).logout();
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

  void _showEditSheet(BuildContext context, WidgetRef ref, profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: profile, ref: ref),
    );
  }
}

// ── Sheet widget ──────────────────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final dynamic profile;
  final WidgetRef ref;
  const _EditProfileSheet({required this.profile, required this.ref});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;

  Uint8List? _imageBytes;
  String? _imageFileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.profile?.fullName ?? '');
    _usernameCtrl =
        TextEditingController(text: widget.profile?.username ?? '');
    _bioCtrl = TextEditingController(text: widget.profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await _showSourceDialog();
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageFileName = picked.name;
    });
  }

  Future<ImageSource?> _showSourceDialog() async {
    if (kIsWeb) return ImageSource.gallery;

    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadAvatar() async {
    if (_imageBytes == null) return widget.profile?.avatarUrl;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final ext = (_imageFileName?.split('.').last ?? 'jpg')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), 'jpg');
    final path = '${user.id}/avatar.$ext';

    await Supabase.instance.client.storage
        .from('avatars')
        .uploadBinary(
          path,
          _imageBytes!,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: true,
          ),
        );

    final url = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(path);

    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final avatarUrl = await _uploadAvatar();
      await updateProfile({
        'full_name': _nameCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
      widget.ref.invalidate(profileProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding:
          EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profil',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),

            // ── Avatar picker ──
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        AppTheme.primary.withValues(alpha: 0.12),
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!) as ImageProvider
                        : (widget.profile?.avatarUrl != null &&
                                widget.profile!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(
                                    widget.profile!.avatarUrl!)
                                as ImageProvider
                            : null,
                    child: (_imageBytes == null &&
                            (widget.profile?.avatarUrl == null ||
                                widget.profile!.avatarUrl!.isEmpty))
                        ? const Icon(Icons.person,
                            size: 48, color: AppTheme.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('Tap untuk ganti foto',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 24),

            // ── Form fields ──
            _buildField(
              controller: _nameCtrl,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _usernameCtrl,
              label: 'Username',
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _bioCtrl,
              label: 'Bio',
              icon: Icons.info_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // ── Tombol ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Simpan',
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label,
          style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right,
          color: Colors.grey[400], size: 20),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    );
  }
}