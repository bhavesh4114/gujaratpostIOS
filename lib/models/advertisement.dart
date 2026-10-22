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
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (raw.startsWith('/')) {
      return 'https://gujaratpost.in$raw';
    }
    return 'https://gujaratpost.in/$raw';
  }

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString(),
      section: json['section']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == null,
      image1: json['image1']?.toString(),
      link1: json['link1']?.toString(),
    );
  }
}
