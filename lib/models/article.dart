class Article {
  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? imageUrl;
  final String? category;
  final String? categorySlug;
  final String? authorName;
  final String timeAgo;
  final DateTime? publishedAt;

  final String? adImageUrl;
  final String? adLink;

  const Article({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    this.imageUrl,
    this.category,
    this.categorySlug,
    this.authorName,
    required this.timeAgo,
    this.publishedAt,
    this.adImageUrl,
    this.adLink,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final title = (json['titleGu'] ?? json['title'] ?? '').toString();
    final slug = (json['slug'] ?? '').toString();
    final id = (json['id'] ?? slug).toString();
    final excerpt = json['excerptGu'] ?? json['excerpt'];
    final content = json['contentGu'] ?? json['content'];

    // Check multiple image fields
    final img = json['image'] ??
        json['featuredImage'] ??
        json['coverImage'] ??
        json['thumbnail'];

    final publishedAtStr = json['publishedAt'] ?? json['createdAt'];
    DateTime? publishedDate;
    String timeAgo = 'Just now';

    if (publishedAtStr != null) {
      try {
        publishedDate = DateTime.parse(publishedAtStr.toString());
        final diff = DateTime.now().difference(publishedDate);
        if (diff.inDays > 1) {
          timeAgo = '${diff.inDays} days ago';
        } else if (diff.inDays == 1) {
          timeAgo = '1 day ago';
        } else if (diff.inHours >= 1) {
          timeAgo = '${diff.inHours} hours ago';
        } else if (diff.inMinutes >= 1) {
          timeAgo = '${diff.inMinutes} minutes ago';
        } else {
          timeAgo = 'Just now';
        }
      } catch (_) {}
    }

    final catName = json['categoryGu'] ?? json['category'];
    final catSlug = json['categorySlug'];

    String? author;
    if (json['author'] != null && json['author'] is Map) {
      final aMap = json['author'] as Map;
      author = (aMap['nameGu'] ?? aMap['name'])?.toString();
    }

    final adImg = json['adImageUrl'] ?? json['adImage'];
    final adLink = json['adLink'] ?? json['adUrl'];

    return Article(
      id: id,
      title: title,
      slug: slug,
      excerpt: excerpt?.toString(),
      content: content?.toString(),
      imageUrl: img?.toString(),
      category: catName?.toString(),
      categorySlug: catSlug?.toString(),
      authorName: author,
      timeAgo: timeAgo,
      publishedAt: publishedDate,
      adImageUrl: adImg?.toString(),
      adLink: adLink?.toString(),
    );
  }
}
