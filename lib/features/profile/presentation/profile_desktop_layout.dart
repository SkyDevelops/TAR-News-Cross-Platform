import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProfileDesktopLayout extends StatelessWidget {
  final Widget
      avatarSection; // avatar, nama, email, username, bio, tombol Edit Profil
  final List<DesktopMenuItemData> menuItems;

  const ProfileDesktopLayout({
    super.key,
    required this.avatarSection,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // kunci: kolom sama tinggi
            children: [
              Expanded(
                flex: 4,
                child: _CardContainer(
                  child: Center(
                      child:
                          avatarSection), // isi kekosongan dgn center vertikal
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 5,
                child: _CardContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (int i = 0; i < menuItems.length; i++) ...[
                        DesktopMenuItem(data: menuItems[i]),
                        if (i != menuItems.length - 1)
                          const Divider(height: 1, indent: 24, endIndent: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _CardContainer(
      {required this.child, this.padding = const EdgeInsets.all(32)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}

class DesktopMenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const DesktopMenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

class DesktopMenuItem extends StatelessWidget {
  final DesktopMenuItemData data;
  const DesktopMenuItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.color ?? AppTheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        hoverColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(data.label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
