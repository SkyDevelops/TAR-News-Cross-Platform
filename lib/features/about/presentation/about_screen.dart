import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home/profile'),
        ),
        title: const Text('Tentang Kami', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              color: AppTheme.primary,
              child: const Column(
                children: [
                  Icon(Icons.newspaper, size: 60, color: Colors.white),
                  SizedBox(height: 16),
                  Text('TAR NEWS',
                      style: TextStyle(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3)),
                  SizedBox(height: 8),
                  Text('Berita Terpercaya untuk Semua',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIXED: added const keyword to _Section constructors
                  const _Section(
                    title: 'TENTANG KAMI',
                    content:
                        'TAR News adalah platform berita digital yang menyajikan informasi terkini dan terpercaya dari berbagai penjuru dunia. Kami berkomitmen untuk memberikan berita yang akurat, berimbang, dan mudah dipahami oleh seluruh lapisan masyarakat.',
                  ),
                  const _Section(
                    title: 'REDAKSI',
                    content:
                        'Tim redaksi TAR News terdiri dari jurnalis berpengalaman dan profesional di bidangnya. Setiap berita melalui proses verifikasi yang ketat sebelum dipublikasikan untuk memastikan keakuratan informasi.',
                  ),
                  const _Section(
                    title: 'MISI KAMI',
                    content:
                        'Menyediakan akses informasi yang mudah, cepat, dan terpercaya bagi seluruh masyarakat Indonesia dan dunia, serta menjadi jembatan informasi antara berbagai lapisan masyarakat.',
                  ),
                  const Divider(height: 32),
                  _MenuItem(
                    title: 'Disclaimer',
                    onTap: () => _showDialog(context, 'Disclaimer',
                        'Konten berita yang ditampilkan di TAR News bersumber dari berbagai media terpercaya. Kami tidak bertanggung jawab atas kerugian yang timbul akibat penggunaan informasi dari platform ini.'),
                  ),
                  _MenuItem(
                    title: 'Term of Services',
                    onTap: () => _showDialog(context, 'Term of Services',
                        'Dengan menggunakan layanan TAR News, Anda menyetujui syarat dan ketentuan yang berlaku. Pengguna dilarang menyebarkan konten yang melanggar hukum melalui platform ini.'),
                  ),
                  _MenuItem(
                    title: 'Privacy Policy',
                    onTap: () => _showDialog(context, 'Privacy Policy',
                        'TAR News berkomitmen untuk melindungi privasi pengguna. Data pribadi yang dikumpulkan hanya digunakan untuk meningkatkan layanan dan tidak akan dijual kepada pihak ketiga.'),
                  ),
                  _MenuItem(
                    title: 'Kontak Kami',
                    onTap: () => _showDialog(context, 'Kontak Kami',
                        'Email: redaksi@tarnews.id\nTelepon: +62 21 1234 5678\nAlamat: Jl. Berita No. 1, Jakarta Pusat, Indonesia'),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text('© 2025 TAR News. All Rights Reserved.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(content, style: const TextStyle(height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.7)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _MenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}