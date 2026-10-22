import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../models/advertisement.dart';
import '../services/news_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final List<Article> relatedArticles;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.relatedArticles = const [],
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  static const Color brandPrimary = Color(0xFFB3121B);

  double _fontSizeDelta = 0.0;
  bool _isBookmarked = false;
  List<Advertisement> _apiAds = [];

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final ads = await NewsService.fetchAds();
      if (mounted && ads.isNotEmpty) {
        setState(() {
          _apiAds = ads;
        });
      }
    } catch (_) {}
  }

  void _adjustFontSize() {
    setState(() {
      if (_fontSizeDelta >= 4.0) {
        _fontSizeDelta = -2.0;
      } else {
        _fontSizeDelta += 2.0;
      }
    });
  }

  void _shareArticle(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform પર સમાચાર શેર થઈ રહ્યા છે...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onOpenAd([String? targetUrl]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          targetUrl != null && targetUrl.isNotEmpty
              ? 'જાહેરાત ખોલી રહ્યા છીએ: $targetUrl'
              : 'જાહેરાત ખોલી રહ્યા છીએ... (Opening Advertisement)',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Format: "20 Oct 2026, 10:37 pm"
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '20 Oct 2026, 10:37 pm';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    int hour = dateTime.hour;
    final isPm = hour >= 12;
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = isPm ? 'pm' : 'am';

    return '$day $month $year, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final relatedList = widget.relatedArticles.isNotEmpty
        ? widget.relatedArticles
            .where((a) => a.id != widget.article.id)
            .toList()
        : <Article>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // 1. Top Header (White background, back arrow, 5 black dots, Bookmark, A, Share)
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          // Center 5 black dots (•••••) matching reference screenshot
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final isMiddle = index == 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: isMiddle ? 6.5 : 4.5,
                height: isMiddle ? 6.5 : 4.5,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          actions: [
            // Bookmark Icon
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? brandPrimary : Colors.black87,
                size: 24,
              ),
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
              },
            ),
            // Text-size 'A'
            InkWell(
              onTap: _adjustFontSize,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            // Share Icon
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black87, size: 24),
              onPressed: () => _shareArticle('General'),
            ),
            const SizedBox(width: 4),
          ],
        ),

        // 2. Single Continuous Vertical Scroll Layout
        body: SafeArea(
          bottom: true,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // News Headline
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  widget.article.title,
                  style: TextStyle(
                    fontSize: 21.5 + _fontSizeDelta,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.28,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // Updated Information (Small & Grey)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Text(
                  'Updated: ${_formatDate(widget.article.publishedAt)} | gujaratpost',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),

              // News Image (Full width, edge-to-edge, square corners)
              if (widget.article.imageUrl != null &&
                  widget.article.imageUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 245,
                  child: Image.network(
                    widget.article.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(Icons.newspaper, size: 48, color: Colors.grey),
                    ),
                  ),
                ),

              // Article Flow (Part 1 + In-Article Advertisement + Part 2 Continuation)
              ..._buildFullArticleWithMidAd(),

              // Share This Article Section
              _buildShareSection(),

              const SizedBox(height: 28),

              // Related Articles Section
              _buildRelatedArticlesSection(relatedList),
            ],
          ),
        ),
      ),
    );
  }

  /// Parses article paragraphs and injects the advertisement right in the middle
  List<Widget> _buildFullArticleWithMidAd() {
    final raw = widget.article.content ?? widget.article.excerpt ?? '';
    if (raw.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'સંપૂર્ણ સમાચાર ટૂંક સમયમાં ઉપલબ્ધ થશે...',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ),
      ];
    }

    // 1. Clean HTML tags and decode HTML entities
    String text = raw
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>\s*<p[^>]*>', caseSensitive: false), '\n\n')
        .replaceAll(
          RegExp(r'</?(?:p|div|section|article)[^>]*>', caseSensitive: false),
          '\n\n',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();

    final rawParagraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    // 2. Separate into individual clean lines/blocks
    final allBlocks = <String>[];
    for (final p in rawParagraphs) {
      final lines = p
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      for (final line in lines) {
        allBlocks.add(line);
      }
    }

    if (allBlocks.isEmpty) {
      return [];
    }

    // 3. Separate Lead Highlights (Bold Summary Lines at top) from Body Paragraphs
    final leadHighlights = <String>[];
    final bodyParagraphs = <String>[];

    int idx = 0;
    while (idx < allBlocks.length && leadHighlights.length < 2) {
      final block = allBlocks[idx];
      final colonIndex = block.indexOf(':');
      final hasCityPrefix = colonIndex > 0 && colonIndex <= 15;
      // Lead highlights are concise lines (<= 140 chars) without a city prefix
      if (block.length <= 140 &&
          !hasCityPrefix &&
          (!block.endsWith('.') || block.length < 90)) {
        leadHighlights.add(block);
        idx++;
      } else {
        break;
      }
    }

    // The remaining blocks are substantive body paragraphs
    while (idx < allBlocks.length) {
      bodyParagraphs.add(allBlocks[idx]);
      idx++;
    }

    // Fallback: If all blocks were caught as highlights, treat them as body
    if (bodyParagraphs.isEmpty && leadHighlights.isNotEmpty) {
      bodyParagraphs.addAll(leadHighlights);
      leadHighlights.clear();
    }

    // If there is only 1 long body paragraph, split across sentences so ad is in the middle
    if (bodyParagraphs.length == 1 && bodyParagraphs[0].length > 250) {
      final sentences = bodyParagraphs[0].split(RegExp(r'(?<=[.!?।])\s+'));
      if (sentences.length >= 2) {
        final mid = (sentences.length / 2).ceil();
        final part1 = sentences.sublist(0, mid).join(' ');
        final part2 = sentences.sublist(mid).join(' ');
        bodyParagraphs.clear();
        bodyParagraphs.add(part1);
        bodyParagraphs.add(part2);
      }
    }

    // 4. Calculate the middle index so advertisement appears right in the middle ("વચ્ચે")
    int midIndex;
    if (bodyParagraphs.length <= 1) {
      midIndex = 1;
    } else if (bodyParagraphs.length == 2 || bodyParagraphs.length == 3) {
      midIndex = (bodyParagraphs.length / 2).ceil();
    } else if (bodyParagraphs.length == 4) {
      // Exactly 2 paragraphs before and 2 paragraphs after
      midIndex = 2;
    } else {
      // For 5 or more paragraphs, put ad roughly half way or at least 2 paragraphs in
      midIndex = (bodyParagraphs.length / 2).floor();
    }

    final widgets = <Widget>[];

    // 5. Render Lead Highlights (Bold, at the top of the article)
    if (leadHighlights.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < leadHighlights.length; i++) ...[
                Text(
                  leadHighlights[i],
                  style: TextStyle(
                    fontSize: 16.5 + _fontSizeDelta,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.35,
                  ),
                ),
                if (i < leadHighlights.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      );
    }

    // 6. First Part of Body Paragraphs (Before Advertisement)
    final firstPartCount = midIndex.clamp(0, bodyParagraphs.length);
    for (int i = 0; i < firstPartCount; i++) {
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            (i == 0 && leadHighlights.isEmpty) ? 16 : 8,
            16,
            8,
          ),
          child: _buildParagraphWithCityPrefix(bodyParagraphs[i]),
        ),
      );
    }

    // 7. In-Article Advertisement — Article ની વચ્ચે (Exactly in the middle!)
    widgets.add(const SizedBox(height: 14));
    widgets.add(_buildInArticleAdvertisement());
    widgets.add(const SizedBox(height: 14));

    // 8. Second Part of Body Paragraphs (After Advertisement continuation)
    for (int i = firstPartCount; i < bodyParagraphs.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildParagraphWithCityPrefix(bodyParagraphs[i]),
        ),
      );
    }

    return widgets;
  }

  /// Builds the in-article advertisement block (Screenshot 2 & 3 style)
  Widget _buildInArticleAdvertisement() {
    String? adImageUrl = widget.article.adImageUrl;
    String? adTargetUrl = widget.article.adLink;

    if (adImageUrl == null || adImageUrl.isEmpty) {
      if (_apiAds.isNotEmpty) {
        final ad = _apiAds.first;
        adImageUrl = ad.resolvedImageUrl;
        adTargetUrl = ad.link1;
      }
    }

    // High quality fallback ad banner matching screenshots
    adImageUrl ??= 'https://gujaratpost.in/adverts/ram_banner.jpg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ADVERTISEMENT Label
        const Text(
          'ADVERTISEMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
            fontFamily: 'sans-serif',
          ),
        ),
        const SizedBox(height: 10),

        // Advertisement Banner Image with rounded corners
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFF1F5F9),
              child: Image.network(
                adImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign, size: 42, color: Color(0xFF0066FE)),
                          SizedBox(height: 6),
                          Text(
                            'Special Offer',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Blue Rounded "Open" Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _onOpenAd(adTargetUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FE),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Open',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds paragraph with bold city/location prefix (e.g. "મુંબઈ:", "અમદાવાદ:")
  Widget _buildParagraphWithCityPrefix(String paragraphText) {
    final colonIndex = paragraphText.indexOf(':');
    if (colonIndex > 0 && colonIndex <= 15) {
      final prefix = paragraphText.substring(0, colonIndex + 1);
      final rest = paragraphText.substring(colonIndex + 1);

      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16 + _fontSizeDelta,
            color: const Color(0xFF1E293B),
            height: 1.55,
            fontFamily: 'NotoSansGujarati',
          ),
          children: [
            TextSpan(
              text: prefix,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: rest,
            ),
          ],
        ),
      );
    }

    return Text(
      paragraphText,
      style: TextStyle(
        fontSize: 16 + _fontSizeDelta,
        color: const Color(0xFF1E293B),
        height: 1.55,
      ),
    );
  }

  /// 4. Share This Article Section (Screenshot 4 style)
  Widget _buildShareSection() {
    return Column(
      children: [
        const SizedBox(height: 28),
        // "Share this article" label
        const Center(
          child: Text(
            'Share this article',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              fontFamily: 'sans-serif',
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal Row with 4 colored buttons: Facebook, Email, X, WhatsApp
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Facebook (Blue)
            _buildSocialShareButton(
              color: const Color(0xFF1877F2),
              icon: Icons.facebook,
              onTap: () => _shareArticle('Facebook'),
            ),
            const SizedBox(width: 12),

            // 2. Email (Red)
            _buildSocialShareButton(
              color: const Color(0xFFEA4335),
              icon: Icons.email,
              onTap: () => _shareArticle('Email'),
            ),
            const SizedBox(width: 12),

            // 3. X / Twitter (Black)
            _buildSocialShareButton(
              color: Colors.black,
              isXIcon: true,
              onTap: () => _shareArticle('X (Twitter)'),
            ),
            const SizedBox(width: 12),

            // 4. WhatsApp (Green)
            _buildSocialShareButton(
              color: const Color(0xFF25D366),
              icon: Icons.chat_bubble,
              onTap: () => _shareArticle('WhatsApp'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialShareButton({
    required Color color,
    IconData? icon,
    bool isXIcon = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 58,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isXIcon
              ? const Text(
                  '𝕏',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  /// 5. Related Articles Section (Screenshot 4 style)
  Widget _buildRelatedArticlesSection(List<Article> relatedList) {
    if (relatedList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading: "Related Articles"
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Related Articles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // List of Related Article items
        ...relatedList.take(4).map(
              (rel) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailScreen(
                          article: rel,
                          relatedArticles: widget.relatedArticles,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail image (16:10 aspect ratio, 8dp radius)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 116,
                          height: 74,
                          color: const Color(0xFFF1F5F9),
                          child: rel.imageUrl != null &&
                                  rel.imageUrl!.isNotEmpty
                              ? Image.network(
                                  rel.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.newspaper,
                                          size: 28, color: Colors.grey),
                                )
                              : const Icon(Icons.newspaper,
                                  size: 28, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Article Title & Time Ago
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rel.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rel.timeAgo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF808080),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
