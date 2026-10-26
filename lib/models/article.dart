class Article {
  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
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
    this.videoUrl,
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

    // Check multiple image fields (ensuring empty string fallback to non-empty fields)
    final dynamic rawImg = [
      json['image'],
      json['featuredImage'],
      json['coverImage'],
      json['thumbnail'],
      json['img'],
      json['imageUrl'],
    ].firstWhere(
      (val) => val != null && val.toString().trim().isNotEmpty,
      orElse: () => null,
    );
    final resolvedImg = resolveImageUrl(rawImg);

    final video = json['videoUrl'] ??
        json['video_url'] ??
        json['youtubeUrl'] ??
        json['youtube_url'] ??
        json['youtubeLink'] ??
        json['videoLink'] ??
        json['video_link'] ??
        json['video'] ??
        json['url'];

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

    final rawAdImg = json['adImageUrl'] ??
        json['adImage'] ??
        json['ad_image'] ??
        json['advertisement_image'] ??
        json['advertisementImage'] ??
        json['adBanner'];
    final rawAdLink = json['adLink'] ??
        json['ad_link'] ??
        json['adUrl'] ??
        json['advertisement_link'] ??
        json['advertisementLink'];
    final adImg = resolveImageUrl(rawAdImg);
    final adLink = rawAdLink?.toString();

    final rawExcerpt = (json['excerptGu'] ?? json['excerpt'])?.toString().trim();
    final rawContent = (json['contentGu'] ?? json['content'])?.toString().trim();
    final cleanExcerpt = (rawExcerpt != null && rawExcerpt.isNotEmpty && rawExcerpt != 'null') ? rawExcerpt : null;
    final cleanContent = (rawContent != null && rawContent.isNotEmpty && rawContent != 'null')
        ? rawContent
        : cleanExcerpt;

    return Article(
      id: id,
      title: title,
      slug: slug,
      excerpt: cleanExcerpt,
      content: cleanContent,
      imageUrl: resolvedImg,
      videoUrl: video?.toString(),
      category: catName?.toString(),
      categorySlug: catSlug?.toString(),
      authorName: author,
      timeAgo: timeAgo,
      publishedAt: publishedDate,
      adImageUrl: adImg?.toString(),
      adLink: adLink?.toString(),
    );
  }

  Article copyWith({
    String? id,
    String? title,
    String? slug,
    String? excerpt,
    String? content,
    String? imageUrl,
    String? videoUrl,
    String? category,
    String? categorySlug,
    String? authorName,
    String? timeAgo,
    DateTime? publishedAt,
    String? adImageUrl,
    String? adLink,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      categorySlug: categorySlug ?? this.categorySlug,
      authorName: authorName ?? this.authorName,
      timeAgo: timeAgo ?? this.timeAgo,
      publishedAt: publishedAt ?? this.publishedAt,
      adImageUrl: adImageUrl ?? this.adImageUrl,
      adLink: adLink ?? this.adLink,
    );
  }

  /// Resolves relative paths, missing schemes, and converts unsupported formats like AVIF to standard JPEG
  static String? resolveImageUrl(dynamic raw) {
    if (raw == null) return null;
    var str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'undefined') return null;

    if (str.startsWith('//')) {
      str = 'https:$str';
    } else if (!str.startsWith('http://') && !str.startsWith('https://')) {
      if (str.startsWith('/uploads')) {
        str = 'https://api.gujaratpost.in$str';
      } else if (str.startsWith('/')) {
        str = 'https://guj-stg.gujaratpost.in$str';
      } else {
        str = 'https://guj-stg.gujaratpost.in/$str';
      }
    }

    if (str.contains('shiva-case.jpg')) {
      return 'https://gujaratpost.in/news/crime.jpg';
    }
    if (str.contains('vande-bharat.jpg')) {
      return 'https://gujaratpost.in/news/train1.jpg';
    }

    // CRITICAL: Flutter's native image engine (Skia / Impeller) cannot decode AVIF format on Android.
    // Cloudinary automatically converts AVIF images to standard JPEG on-the-fly when requesting .jpg or f_jpg.
    if (str.contains('res.cloudinary.com')) {
      // 1. Replace .avif extension with .jpg
      str = str.replaceAll(RegExp(r'\.avif(\b|\?|$)', caseSensitive: false), '.jpg');
      // 2. Add format transformation f_jpg,q_auto if not present in Cloudinary upload path
      if (str.contains('/image/upload/') && !str.contains('/f_')) {
        str = str.replaceFirst('/image/upload/', '/image/upload/f_jpg,q_auto/');
      }
    } else if (str.contains('.avif')) {
      str = str.replaceAll(RegExp(r'\.avif(\b|\?|$)', caseSensitive: false), '.jpg');
    }

    return str;
  }

  /// Returns the resolved image URL or a context-matched news photo
  String get displayImageUrl {
    final resolved = resolveImageUrl(imageUrl);
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }
    final cat = (categorySlug ?? category ?? title).toLowerCase();
    if (cat.contains('crime') || cat.contains('પોલીસ') || cat.contains('હત્યા')) {
      return 'https://gujaratpost.in/news/crime.jpg';
    }
    if (cat.contains('court') || cat.contains('કોર્ટ') || cat.contains('જામીન')) {
      return 'https://gujaratpost.in/news/court.jpg';
    }
    if (cat.contains('fire') || cat.contains('આગ')) {
      return 'https://gujaratpost.in/news/fire.jpg';
    }
    if (cat.contains('accident') || cat.contains('અકસ્માત')) {
      return 'https://gujaratpost.in/news/accident.jpg';
    }
    if (cat.contains('sports') || cat.contains('cricket')) {
      return 'https://gujaratpost.in/news/cricket.jpg';
    }
    if (cat.contains('politics') || cat.contains('bjp')) {
      return 'https://gujaratpost.in/news/bjp.jpg';
    }
    if (cat.contains('business') || cat.contains('વેપાર')) {
      return 'https://gujaratpost.in/news/business.jpg';
    }
    if (cat.contains('train') || cat.contains('રેલવે') || cat.contains('મેટ્રો')) {
      return 'https://gujaratpost.in/news/train.jpg';
    }
    if (cat.contains('weather') || cat.contains('rain') || cat.contains('વરસાદ')) {
      return 'https://gujaratpost.in/news/rain.jpg';
    }
    if (cat.contains('delhi') || cat.contains('પ્રદૂષણ')) {
      return 'https://gujaratpost.in/news/delhi.jpg';
    }
    return 'https://gujaratpost.in/news/tiger1.jpg';
  }
}
