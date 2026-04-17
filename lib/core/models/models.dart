class Article {
  final String id;
  final String title;
  final String? content;
  final String? summary;
  final String? imageUrl;
  final String? sourceName;
  final String? sourceUrl;
  final String? category;
  final DateTime? publishedAt;
  bool isBookmarked;

  Article({
    required this.id,
    required this.title,
    this.content,
    this.summary,
    this.imageUrl,
    this.sourceName,
    this.sourceUrl,
    this.category,
    this.publishedAt,
    this.isBookmarked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        content: json['content'] as String?,
        summary: json['summary'] as String?,
        imageUrl: json['image_url'] as String?,
        sourceName: json['source_name'] as String?,
        sourceUrl: json['source_url'] as String?,
        category: json['category'] as String?,
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'].toString())
            : null,
      );

  String get timeAgo {
    if (publishedAt == null) return '';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
  }
}

class UserProfile {
  final String id;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? '',
        fullName: json['full_name'] as String?,
        username: json['username'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'username': username,
        'avatar_url': avatarUrl,
        'bio': bio,
      };
}