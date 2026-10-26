import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../models/advertisement.dart';
import '../services/news_service.dart';
import '../widgets/cylindrical_page_curl.dart';

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

/// Global reader preferences for Gujarat Post reader mode
class ReaderPreferences {
  static double fontSize = 15.0; // range 13.0 to 24.0
  static bool isDarkMode = false;
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  static const Color brandPrimary = Color(0xFFB3121B);

  late List<Article> _articles;
  final GlobalKey<CylindricalPageCurlState> _curlKey =
      GlobalKey<CylindricalPageCurlState>();
  int _currentPage = 0;

  double _readerFontSize = ReaderPreferences.fontSize;
  bool _isDarkMode = ReaderPreferences.isDarkMode;
  double get _fontSizeDelta => _readerFontSize - 15.0;

  final Set<String> _bookmarkedIds = {};
  List<Advertisement> _apiAds = [];
  final Set<String> _fetchedDetailSlugs = {};

  @override
  void initState() {
    super.initState();
    _readerFontSize = ReaderPreferences.fontSize;
    _isDarkMode = ReaderPreferences.isDarkMode;

    // Prepare continuous article feed for horizontal swiping
    final initialArticles = <Article>[];
    if (widget.relatedArticles.isNotEmpty) {
      final existingIndex =
          widget.relatedArticles.indexWhere((a) => a.id == widget.article.id);
      if (existingIndex >= 0) {
        initialArticles.addAll(widget.relatedArticles);
        _currentPage = existingIndex;
      } else {
        initialArticles.add(widget.article);
        for (final art in widget.relatedArticles) {
          if (art.id != widget.article.id) {
            initialArticles.add(art);
          }
        }
        _currentPage = 0;
      }
    } else {
      initialArticles.add(widget.article);
      _currentPage = 0;
    }

    _articles = initialArticles;
    _loadAds();
    _fetchArticleDetail(_currentPage);
    if (_currentPage + 1 < _articles.length) {
      _fetchArticleDetail(_currentPage + 1);
    }
  }

  Future<void> _fetchArticleDetail(int index) async {
    if (index < 0 || index >= _articles.length) return;
    final art = _articles[index];
    final slugOrId = art.slug.isNotEmpty ? art.slug : art.id;
    if (slugOrId.isEmpty || _fetchedDetailSlugs.contains(slugOrId)) return;
    _fetchedDetailSlugs.add(slugOrId);

    try {
      final full = await NewsService.fetchArticleDetail(slugOrId);
      if (full != null && mounted) {
        setState(() {
          final updated = art.copyWith(
            content: (full.content != null && full.content!.isNotEmpty)
                ? full.content
                : art.content,
            excerpt: (full.excerpt != null && full.excerpt!.isNotEmpty)
                ? full.excerpt
                : art.excerpt,
            imageUrl: (full.imageUrl != null && full.imageUrl!.isNotEmpty)
                ? full.imageUrl
                : art.imageUrl,
            authorName: full.authorName ?? art.authorName,
            publishedAt: full.publishedAt ?? art.publishedAt,
            adImageUrl: full.adImageUrl ?? art.adImageUrl,
            adLink: full.adLink ?? art.adLink,
          );
          _articles[index] = updated;
        });
      }
    } catch (_) {}
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

  Article get _currentArticle =>
      _articles.isNotEmpty ? _articles[_currentPage] : widget.article;

  void _showReaderSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = _isDarkMode;
            final sheetBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF111827);
            final pillBg =
                isDark ? const Color(0xFF27272A) : const Color(0xFFF1F3F5);

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Select Font Size Header
                    Text(
                      'Select Font Size',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Font Size Slider Row
                    Row(
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'sans-serif',
                            color: textColor,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF00D09C),
                              inactiveTrackColor: isDark
                                  ? const Color(0xFF3F3F46)
                                  : const Color(0xFFE5E7EB),
                              thumbColor: const Color(0xFF00D09C),
                              overlayColor: const Color(0x3300D09C),
                              trackHeight: 3.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 9.0,
                                elevation: 2.0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 18.0,
                              ),
                              tickMarkShape: const RoundSliderTickMarkShape(
                                tickMarkRadius: 2.0,
                              ),
                              activeTickMarkColor: Colors.transparent,
                              inactiveTickMarkColor: isDark
                                  ? const Color(0xFF52525B)
                                  : const Color(0xFFD1D5DB),
                            ),
                            child: Slider(
                              value: _readerFontSize.clamp(13.0, 24.0),
                              min: 13.0,
                              max: 24.0,
                              divisions: 11,
                              onChanged: (val) {
                                setModalState(() {
                                  _readerFontSize = val;
                                });
                                setState(() {
                                  _readerFontSize = val;
                                });
                                ReaderPreferences.fontSize = val;
                              },
                            ),
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'sans-serif',
                            color: textColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // 2. Select Mode Header
                    Text(
                      'Select Mode',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Segmented Light / Dark Toggle Pill
                    Container(
                      width: 190,
                      height: 46,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          // Light Mode Option
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (_isDarkMode) {
                                  setModalState(() {
                                    _isDarkMode = false;
                                  });
                                  setState(() {
                                    _isDarkMode = false;
                                  });
                                  ReaderPreferences.isDarkMode = false;
                                }
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: !_isDarkMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: !_isDarkMode
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Light',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: !_isDarkMode
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !_isDarkMode
                                        ? Colors.black
                                        : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Dark Mode Option
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (!_isDarkMode) {
                                  setModalState(() {
                                    _isDarkMode = true;
                                  });
                                  setState(() {
                                    _isDarkMode = true;
                                  });
                                  ReaderPreferences.isDarkMode = true;
                                }
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: _isDarkMode
                                      ? const Color(0xFF3F3F46)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _isDarkMode
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Dark',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: _isDarkMode
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareArticle(String platform, [Article? article]) {
    final title = article?.title ?? _currentArticle.title;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform પર "$title" શેર થઈ રહ્યા છે...'),
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

  // Format: "21 Oct 2026, 08:47 PM" matching reference image exactly
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '21 Oct 2026, 08:47 PM';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    int hour = dateTime.hour;
    final isPm = hour >= 12;
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final hourStr = hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';

    return '$day $month $year, $hourStr:$minute $period';
  }

  // Format for related news: "October 21, 20:44"
  String _formatRelatedDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'October 21, 20:44';
    }
    const fullMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = fullMonths[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = _bookmarkedIds.contains(_currentArticle.id);
    final isDark = _isDarkMode;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final appbarBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final headerIconColor = isDark ? Colors.white : Colors.black87;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appbarBg,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: appbarBg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        // Top Header matching reference image: back chevron, capsule pill with active red dot
        appBar: AppBar(
          backgroundColor: appbarBg,
          foregroundColor: headerIconColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: headerIconColor,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          // Center capsule pill with red active dot and grey inactive dots
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (index) {
                final isActive = (_currentPage % 8) == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: isActive ? 6.5 : 5.5,
                  height: isActive ? 6.5 : 5.5,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE50914) // Bright red active dot matching reference image
                        : (isDark
                            ? const Color(0xFF52525B)
                            : const Color(0xFFD1D1D6)), // Subtle light grey inactive dots
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
          actions: [
            // 1. Bookmark Button (matching reference image)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? brandPrimary : headerIconColor,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  if (isBookmarked) {
                    _bookmarkedIds.remove(_currentArticle.id);
                  } else {
                    _bookmarkedIds.add(_currentArticle.id);
                  }
                });
              },
              tooltip: 'Bookmark',
            ),

            // 2. Font Size ('A', serif font matching reference image)
            InkWell(
              onTap: () => _showReaderSettingsBottomSheet(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Text(
                  'A',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                    color: headerIconColor,
                  ),
                ),
              ),
            ),

            // 3. Share Button (connected nodes share icon matching reference image)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                Icons.share,
                color: headerIconColor,
                size: 20,
              ),
              onPressed: () => _shareArticle('General', _currentArticle),
              tooltip: 'Share',
            ),
            const SizedBox(width: 6),
          ],
        ),

        // 3D Cylindrical Page Curl Flip View
        body: SafeArea(
          bottom: true,
          child: CylindricalPageCurl(
            key: _curlKey,
            itemCount: _articles.length,
            initialIndex: _currentPage,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _fetchArticleDetail(index);
              if (index + 1 < _articles.length) {
                _fetchArticleDetail(index + 1);
              }
            },
            itemBuilder: (context, index) {
              final article = _articles[index];
              return _buildArticleScrollContent(article);
            },
          ),
        ),
      ),
    );
  }

  /// Builds the full scrollable page for a single article
  Widget _buildArticleScrollContent(Article article) {
    final relatedList =
        _articles.where((a) => a.id != article.id).toList();
    final isDark = _isDarkMode;
    final textHeadlineColor = isDark ? Colors.white : Colors.black;
    final authorColor = isDark ? Colors.white : const Color(0xFF111827);
    final dateColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF111827);
    final authorName = (article.authorName != null && article.authorName!.trim().isNotEmpty)
        ? article.authorName!.trim()
        : 'Gujaratpost';

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // Top Advertisement Banner above News Headline (as requested)
          _buildTopAdvertisement(article),

          // News Headline matching reference image exactly
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              article.title,
              style: TextStyle(
                fontFamily: 'NotoSansGujarati',
                fontSize: 21.0 + _fontSizeDelta,
                fontWeight: FontWeight.w700,
                color: textHeadlineColor,
                height: 1.30,
                letterSpacing: -0.25,
              ),
            ),
          ),

          // Space between headline and Author
          const SizedBox(height: 14),

          // Author & Date Section (matching reference image: Gujaratpost on top, Date below)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: authorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(article.publishedAt),
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: dateColor,
                  ),
                ),
              ],
            ),
          ),

          // Space between Date and Image
          const SizedBox(height: 18),

          // News Image (with 16px horizontal margins and rounded corners matching reference image!)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 230,
                child: Image.network(
                  article.displayImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  headers: const {
                    'User-Agent':
                        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF242B38), Color(0xFF131822)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/gujarat_post_logo.png',
                        width: 110,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.newspaper,
                          size: 48,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Article Flow (Part 1 + In-Article Advertisement + Part 2 Continuation)
          ..._buildFullArticleWithMidAd(article),

          // "Share this article" Section (directly after article content finishes, before Related News)
          _buildShareThisArticleSection(article),

          // Related News Section
          _buildRelatedNewsSection(relatedList),
        ],
      ),
    );
  }

  /// Parses article paragraphs and injects the advertisement right in the middle
  List<Widget> _buildFullArticleWithMidAd(Article article) {
    String raw = (article.content ?? '').trim();
    if (raw.isEmpty) {
      raw = (article.excerpt ?? '').trim();
    }
    final isDark = _isDarkMode;

    if (raw.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'સંપૂર્ણ સમાચાર લોડ થઈ રહ્યા છે...',
                    style: TextStyle(
                      fontSize: 14 + _fontSizeDelta,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInArticleAdvertisement(article),
            ],
          ),
        ),
      ];
    }

    // Clean HTML tags and decode HTML entities
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

    // Strip markdown dividers and heading markers while preserving text
    text = text.replaceAll(RegExp(r'---+\s*'), '\n\n');
    text = text.replaceAll(RegExp(r'##+\s*(?:📌)?\s*'), '');

    final rawParagraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

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

    // Separate Lead Highlights from Body Paragraphs
    final leadHighlights = <String>[];
    final bodyParagraphs = <String>[];

    for (final block in allBlocks) {
      var item = block;
      bool isBullet = false;
      if (item.startsWith('- ') || item.startsWith('* ') || item.startsWith('• ')) {
        item = item.substring(2).trim();
        isBullet = true;
      }
      if (item.isEmpty) continue;

      final colonIndex = item.indexOf(':');
      final hasCityPrefix = colonIndex > 0 && colonIndex <= 15;

      // Highlights: bullets or short leading key statements
      if (bodyParagraphs.isEmpty &&
          leadHighlights.length < 2 &&
          (isBullet || (item.length <= 140 && !hasCityPrefix && (!item.endsWith('.') || item.length < 80)))) {
        leadHighlights.add(item);
      } else {
        bodyParagraphs.add(item);
      }
    }

    if (bodyParagraphs.isEmpty && leadHighlights.isNotEmpty) {
      bodyParagraphs.addAll(leadHighlights);
      leadHighlights.clear();
    }

    // If only 1 body paragraph exists, split it in half so the Ad can sit in the middle
    if (bodyParagraphs.length == 1) {
      final p = bodyParagraphs[0];
      final sentences = p.split(RegExp(r'(?<=[.!?।])\s+'));
      if (sentences.length >= 2) {
        final mid = (sentences.length / 2).ceil();
        final part1 = sentences.sublist(0, mid).join(' ');
        final part2 = sentences.sublist(mid).join(' ');
        bodyParagraphs.clear();
        bodyParagraphs.add(part1);
        bodyParagraphs.add(part2);
      } else if (p.length > 80) {
        final mid = (p.length / 2).floor();
        final spaceIdx = p.indexOf(' ', mid);
        if (spaceIdx != -1) {
          bodyParagraphs.clear();
          bodyParagraphs.add(p.substring(0, spaceIdx).trim());
          bodyParagraphs.add(p.substring(spaceIdx).trim());
        }
      }
    }

    int midIndex;
    if (bodyParagraphs.length <= 1) {
      midIndex = 1;
    } else {
      midIndex = (bodyParagraphs.length / 2).ceil();
    }

    final widgets = <Widget>[];

    // Render Lead Highlights as Bullet Points (Matching Reference Image)
    if (leadHighlights.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < leadHighlights.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•  ',
                        style: TextStyle(
                          fontSize: 16.0 + _fontSizeDelta,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF3F4F6) : Colors.black,
                          height: 1.35,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          leadHighlights[i],
                          style: TextStyle(
                            fontFamily: 'NotoSansGujarati',
                            fontSize: 15.5 + _fontSizeDelta,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFF3F4F6) : Colors.black,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // First Part of Body Paragraphs
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

    // In-Article Advertisement right in the middle
    widgets.add(const SizedBox(height: 14));
    widgets.add(_buildInArticleAdvertisement(article));
    widgets.add(const SizedBox(height: 14));

    // Second Part of Body Paragraphs
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

  /// Builds the top advertisement banner displayed above the News Headline.
  /// Only renders when a real advertisement is provided by the backend API or article.
  Widget _buildTopAdvertisement(Article article) {
    String? adImageUrl = article.adImageUrl?.trim();
    String? adTargetUrl = article.adLink?.trim();
    final isDark = _isDarkMode;

    if (adImageUrl == null || adImageUrl.isEmpty) {
      if (_apiAds.isNotEmpty) {
        final ad = _apiAds.firstWhere(
          (a) =>
              (a.section == 'top' || a.section == 'article') &&
              (a.resolvedImageUrl?.isNotEmpty ?? false),
          orElse: () => _apiAds.firstWhere(
            (a) => a.resolvedImageUrl != null && a.resolvedImageUrl!.isNotEmpty,
            orElse: () => _apiAds.first,
          ),
        );
        adImageUrl = ad.resolvedImageUrl?.trim();
        adTargetUrl = ad.link1?.trim();
      }
    }

    // When the backend does not provide an advertisement, do NOT show a fixed/fake card
    if (adImageUrl == null || adImageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    adTargetUrl ??= 'https://gujaratpost.in/';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ADVERTISEMENT',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _onOpenAd(adTargetUrl),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      adImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 110,
                      headers: const {
                        'User-Agent':
                            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: brandPrimary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Open',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the in-article advertisement matching Screenshot 2 (Blinkit Card)
  Widget _buildInArticleAdvertisement(Article article) {
    final isDark = _isDarkMode;
    final adTargetUrl = article.adLink ??
        (_apiAds.isNotEmpty ? _apiAds.first.link1 : null) ??
        'https://blinkit.com/';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ADVERTISEMENT label matching Screenshot 2
        Text(
          'ADVERTISEMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontFamily: 'sans-serif',
          ),
        ),
        const SizedBox(height: 10),

        // Blinkit In-Article Card matching Screenshot 2 & Android gp-blinkit-card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF161D27), Color(0xFF0E131B)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Blinkit Squircle Logo (Bright Yellow)
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8CB15),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'blinkit',
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.black,
                          letterSpacing: -0.4,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '10 min app',
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontWeight: FontWeight.w700,
                          fontSize: 7.5,
                          color: Color(0xFF1F2937),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // App Title
                const Text(
                  'Blinkit',
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),

                // ✓ Installed Subtitle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Installed',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 12.5,
                        color: Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Blue Pill "Open" Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _onOpenAd(adTargetUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FE),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0x660066FE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'Open',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds paragraph with bold city/location prefix
  Widget _buildParagraphWithCityPrefix(String paragraphText) {
    final colonIndex = paragraphText.indexOf(':');
    final isDark = _isDarkMode;
    final textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
    final prefixColor = isDark ? Colors.white : Colors.black;

    if (colonIndex > 0 && colonIndex <= 15) {
      final prefix = paragraphText.substring(0, colonIndex + 1);
      final rest = paragraphText.substring(colonIndex + 1);

      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16 + _fontSizeDelta,
            color: textColor,
            height: 1.55,
            fontFamily: 'NotoSansGujarati',
          ),
          children: [
            TextSpan(
              text: prefix,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: prefixColor,
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
        fontFamily: 'NotoSansGujarati',
        fontSize: 15.5 + _fontSizeDelta,
        color: textColor,
        height: 1.55,
      ),
    );
  }

  /// Related News Section matching Screenshot 1 exactly
  Widget _buildRelatedNewsSection(List<Article> relatedList) {
    if (relatedList.isEmpty) return const SizedBox.shrink();
    final isDark = _isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Heading: Document/News Icon + "Related News"
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
          child: Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 24,
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 8),
              Text(
                'Related News',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        // All Related News Items
        ...relatedList.map((rel) {
          final isRelBookmarked = _bookmarkedIds.contains(rel.id);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: InkWell(
                  onTap: () {
                    final targetIndex =
                        _articles.indexWhere((a) => a.id == rel.id);
                    if (targetIndex >= 0) {
                      _curlKey.currentState?.animateToPage(targetIndex);
                    } else {
                      setState(() {
                        _articles.add(rel);
                      });
                      _curlKey.currentState
                          ?.animateToPage(_articles.length - 1);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail image on the left (~116 × 84 logical px, rounded corners)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 116,
                          height: 84,
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
                          child: Image.network(
                            rel.displayImageUrl,
                            fit: BoxFit.cover,
                            headers: const {
                              'User-Agent':
                                  'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFF2A2E39),
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: 0.45,
                                child: Image.asset(
                                  'assets/images/gujarat_post_logo.png',
                                  width: 48,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.newspaper,
                                    size: 32,
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Gujarati headline + date & action row on the right
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 84),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Gujarati headline text
                              Text(
                                rel.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1E293B),
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Date and actions row (flexible to avoid horizontal overflow on any device)
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 13,
                                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _formatRelatedDate(rel.publishedAt),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Bookmark icon
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        if (isRelBookmarked) {
                                          _bookmarkedIds.remove(rel.id);
                                        } else {
                                          _bookmarkedIds.add(rel.id);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(
                                        isRelBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 18,
                                        color: isRelBookmarked
                                            ? brandPrimary
                                            : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // iOS Share icon
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _shareArticle('Article'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(
                                        Icons.ios_share,
                                        size: 18,
                                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Thin divider under each item
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 16,
                  thickness: 0.8,
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Builds "Share this article" section with 4 social sharing buttons
  /// positioned directly at the end of the article content, before Related News
  Widget _buildShareThisArticleSection(Article article) {
    final isDark = _isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Share this article',
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Facebook Button (Blue)
              _buildSocialShareButton(
                label: 'Facebook',
                bgColor: const Color(0xFF1877F2),
                icon: const CustomPaint(
                  size: Size(18, 18),
                  painter: _FacebookLogoPainter(),
                ),
                onTap: () => _shareArticle('Facebook', article),
              ),
              const SizedBox(width: 14),

              // 2. Email Button (Red)
              _buildSocialShareButton(
                label: 'Email',
                bgColor: const Color(0xFFEA4335),
                icon: const Icon(
                  Icons.mail,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: () => _shareArticle('Email', article),
              ),
              const SizedBox(width: 14),

              // 3. X / Twitter Button (Black)
              _buildSocialShareButton(
                label: 'X',
                bgColor: Colors.black,
                icon: const CustomPaint(
                  size: Size(16, 16),
                  painter: _XLogoPainter(),
                ),
                onTap: () => _shareArticle('X', article),
              ),
              const SizedBox(width: 14),

              // 4. WhatsApp Button (Green)
              _buildSocialShareButton(
                label: 'WhatsApp',
                bgColor: const Color(0xFF25D366),
                icon: const CustomPaint(
                  size: Size(20, 20),
                  painter: _WhatsAppLogoPainter(),
                ),
                onTap: () => _shareArticle('WhatsApp', article),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual social share button with rounded corners and gentle shadow
  Widget _buildSocialShareButton({
    required String label,
    required Color bgColor,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 48,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.28),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

/// Vector painter for the official Facebook 'f' logo
class _FacebookLogoPainter extends CustomPainter {
  const _FacebookLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final path = Path()
      ..moveTo(13.4, 21.0)
      ..lineTo(13.4, 12.8)
      ..lineTo(16.16, 12.8)
      ..lineTo(16.58, 9.6)
      ..lineTo(13.4, 9.6)
      ..lineTo(13.4, 7.55)
      ..cubicTo(13.4, 6.62, 13.66, 6.0, 15.0, 6.0)
      ..lineTo(16.68, 6.0)
      ..lineTo(16.68, 3.13)
      ..cubicTo(16.39, 3.09, 15.39, 3.0, 14.2, 3.0)
      ..cubicTo(11.76, 3.0, 10.08, 4.49, 10.08, 7.23)
      ..lineTo(10.08, 9.6)
      ..lineTo(7.33, 9.6)
      ..lineTo(7.33, 12.8)
      ..lineTo(10.08, 12.8)
      ..lineTo(10.08, 21.0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector painter for the official X (formerly Twitter) logo
class _XLogoPainter extends CustomPainter {
  const _XLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final path = Path()
      ..moveTo(18.244, 2.25)
      ..lineTo(21.552, 2.25)
      ..lineTo(14.325, 10.51)
      ..lineTo(22.827, 21.75)
      ..lineTo(16.17, 21.75)
      ..lineTo(10.956, 14.933)
      ..lineTo(4.99, 21.75)
      ..lineTo(1.68, 21.75)
      ..lineTo(9.41, 12.915)
      ..lineTo(1.254, 2.25)
      ..lineTo(8.08, 2.25)
      ..lineTo(12.793, 8.481)
      ..close()
      ..moveTo(17.083, 19.77)
      ..lineTo(18.916, 19.77)
      ..lineTo(7.084, 4.126)
      ..lineTo(5.117, 4.126)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector painter for the official WhatsApp logo
class _WhatsAppLogoPainter extends CustomPainter {
  const _WhatsAppLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final path = Path()
      ..moveTo(0.057, 24.0)
      ..lineTo(1.744, 17.837)
      ..cubicTo(0.703, 16.033, 0.156, 13.988, 0.157, 11.891)
      ..cubicTo(0.16, 5.335, 5.495, 0.0, 12.05, 0.0)
      ..cubicTo(15.231, 0.001, 18.217, 1.24, 20.463, 3.488)
      ..cubicTo(22.708, 5.736, 23.944, 8.724, 23.943, 11.902)
      ..cubicTo(23.94, 18.459, 18.605, 23.794, 12.05, 23.794)
      ..cubicTo(10.06, 23.793, 8.099, 23.294, 6.362, 22.346)
      ..close()
      ..moveTo(6.654, 20.193)
      ..cubicTo(8.33, 21.188, 9.93, 21.784, 12.046, 21.785)
      ..cubicTo(17.494, 21.785, 21.932, 17.351, 21.935, 11.9)
      ..cubicTo(21.937, 6.438, 17.52, 2.01, 12.054, 2.008)
      ..cubicTo(6.602, 2.008, 2.167, 6.442, 2.165, 11.892)
      ..cubicTo(2.164, 14.117, 2.816, 15.783, 3.911, 17.526)
      ..lineTo(2.912, 21.174)
      ..close()
      ..moveTo(17.984, 14.729)
      ..cubicTo(17.91, 14.605, 17.712, 14.531, 17.414, 14.382)
      ..cubicTo(17.117, 14.233, 15.656, 13.514, 15.383, 13.415)
      ..cubicTo(15.111, 13.316, 14.913, 13.266, 14.714, 13.564)
      ..cubicTo(14.516, 13.861, 13.946, 14.531, 13.773, 14.729)
      ..cubicTo(13.6, 14.927, 13.426, 14.952, 13.129, 14.803)
      ..cubicTo(12.832, 14.654, 11.874, 14.241, 10.739, 13.228)
      ..cubicTo(9.856, 12.44, 9.259, 11.467, 9.086, 11.169)
      ..cubicTo(8.913, 10.872, 9.068, 10.711, 9.216, 10.563)
      ..cubicTo(9.35, 10.43, 9.513, 10.216, 9.662, 10.042)
      ..cubicTo(9.813, 9.87, 9.862, 9.746, 9.962, 9.547)
      ..cubicTo(10.061, 9.349, 10.012, 9.175, 9.937, 9.026)
      ..cubicTo(9.862, 8.878, 9.268, 7.415, 9.021, 6.82)
      ..cubicTo(8.779, 6.241, 8.534, 6.319, 8.352, 6.31)
      ..lineTo(7.782, 6.3)
      ..cubicTo(7.584, 6.3, 7.262, 6.374, 6.99, 6.672)
      ..cubicTo(6.718, 6.97, 5.95, 7.688, 5.95, 9.151)
      ..cubicTo(5.95, 10.614, 7.015, 12.027, 7.163, 12.225)
      ..cubicTo(7.312, 12.423, 9.258, 15.425, 12.239, 16.712)
      ..cubicTo(12.948, 17.018, 13.502, 17.201, 13.933, 17.338)
      ..cubicTo(14.645, 17.564, 15.293, 17.532, 15.805, 17.456)
      ..cubicTo(16.376, 17.371, 17.563, 16.737, 17.811, 16.043)
      ..cubicTo(18.059, 15.348, 18.059, 14.753, 17.984, 14.629)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
