class Advertisement {
  final String id;
  final String? title;
  final String? section;
  final bool isActive;
  final String? image1;
  final String? link1;

  const Advertisement({
    required this.id,
    this.title,
    this.section,
    this.isActive = true,
    this.image1,
    this.link1,
  });

  String? get resolvedImageUrl {
    final raw = image1?.trim();
    if (raw == null || raw.isEmpty) return null;
    var str = raw;
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

    if (str.contains('res.cloudinary.com')) {
      str = str.replaceAll(RegExp(r'\.avif(\b|\?|$)', caseSensitive: false), '.jpg');
      if (str.contains('/image/upload/') && !str.contains('/f_')) {
        str = str.replaceFirst('/image/upload/', '/image/upload/f_jpg,q_auto/');
      }
    } else if (str.contains('.avif')) {
      str = str.replaceAll(RegExp(r'\.avif(\b|\?|$)', caseSensitive: false), '.jpg');
    }

    return str;
  }

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    final rawImg = json['image1'] ??
        json['image'] ??
        json['imageUrl'] ??
        json['adImage'] ??
        json['bannerImage'] ??
        json['mediaUrl'];
    final rawLink = json['link1'] ??
        json['link'] ??
        json['targetUrl'] ??
        json['adLink'] ??
        json['url'];
    return Advertisement(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? json['titleGu'])?.toString(),
      section: json['section']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == null,
      image1: rawImg?.toString(),
      link1: rawLink?.toString(),
    );
  }
}
