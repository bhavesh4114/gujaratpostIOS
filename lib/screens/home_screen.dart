import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_screen.dart';
import 'shorts_feed_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Gujarat Post Brand Identity Colors (matching Android colors.xml)
  static const Color brandPrimary = Color(0xFFB3121B);
  static const Color brandRed = Color(0xFFDC2626);

  bool _isDarkMode = false;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  // Categories list matching Android getDefaultCategories()
  final List<NewsCategory> _categories = NewsService.defaultCategories;

  int _selectedCategoryIndex = 0;
  bool _isLoading = false;
  List<Article> _allArticles = [];
  List<CategorySectionGroup> _homeGroups = [];

  // Track active carousel dot index for each carousel category
  final Map<String, int> _carouselActiveIndex = {};

  @override
  void initState() {
    super.initState();
    _allArticles = NewsService.fallbackArticles;
    _homeGroups = NewsService.buildHomeGroups(_allArticles);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final articles = await NewsService.fetchArticles();

    if (mounted) {
      setState(() {
        _allArticles = articles;
        _homeGroups = NewsService.buildHomeGroups(articles);
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFeed() async {
    final slug = _categories[_selectedCategoryIndex].slug;
    final query = _searchController.text.trim();

    final fetched = await NewsService.fetchArticles(
      categorySlug: slug == 'all' ? null : slug,
      query: query.isEmpty ? null : query,
    );

    if (mounted) {
      setState(() {
        if (slug == 'all') {
          _allArticles = fetched;
          _homeGroups = NewsService.buildHomeGroups(fetched);
        } else {
          _allArticles = fetched;
        }
      });
    }
  }

  void _onCategorySelected(int index) {
    // Videos tab (index 1 / slug 'videos') → open ShortsFeedScreen directly.
    // No intermediate list screen is shown.
    if (_categories[index].slug == 'videos') {
      _openVideosFeed();
      return;
    }
    if (_selectedCategoryIndex == index) return;
    setState(() {
      _selectedCategoryIndex = index;
    });
    _refreshFeed();
  }

  /// Fetch video articles (or reuse what we have) then push the Shorts player.
  Future<void> _openVideosFeed({Article? startAt}) async {
    // Show a brief loading indicator while fetching
    List<Article> videoList = _allArticles
        .where((a) => _youtubeId(a.videoUrl) != null)
        .toList();

    if (videoList.isEmpty) {
      // Fetch from network if we don't have any yet
      final fetched = await NewsService.fetchArticles(categorySlug: 'videos');
      if (mounted) {
        videoList = fetched.where((a) => _youtubeId(a.videoUrl) != null).toList();
      }
    }

    if (!mounted) return;

    final idx = startAt == null
        ? 0
        : videoList.indexWhere((a) => a.id == startAt.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShortsFeedScreen(
          videos: videoList,
          initialIndex: idx >= 0 ? idx : 0,
        ),
      ),
    );
  }

  void _openArticleDetail(Article article) {
    // If the article has a YouTube videoUrl → open ShortsFeedScreen directly.
    final videoId = _youtubeId(article.videoUrl);
    if (videoId != null) {
      _openVideosFeed(startAt: article);
      return;
    }
    // Normal article → article detail screen.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: article,
          relatedArticles: _allArticles,
        ),
      ),
    );
  }

  String? _youtubeId(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host == 'youtu.be' || host == 'www.youtu.be') {
      return uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    }
    if (host == 'youtube.com' || host == 'www.youtube.com' || host == 'm.youtube.com') {
      if (uri.path == '/watch') return uri.queryParameters['v'];
      if (uri.pathSegments.length >= 2 &&
          {'shorts', 'embed', 'live'}.contains(uri.pathSegments.first)) {
        return uri.pathSegments[1];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF0F1015) : Colors.white;
    final surfaceColor = _isDarkMode ? const Color(0xFF18181B) : Colors.white;
    final textPrimary = _isDarkMode ? const Color(0xFFF1F5F9) : Colors.black;
    final textSecondary =
        _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor =
        _isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);

    final isHomeFeed = _categories[_selectedCategoryIndex].slug == 'all';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: surfaceColor,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness:
            _isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: PopScope(
        canPop: _selectedCategoryIndex == 0 && !_isSearchOpen,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_isSearchOpen) {
            setState(() {
              _isSearchOpen = false;
              _searchController.clear();
            });
            _refreshFeed();
          } else if (_selectedCategoryIndex != 0) {
            _onCategorySelected(0);
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
        backgroundColor: bgColor,
        drawer: _buildNavigationDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isDarkMode ? 0.3 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: _isSearchOpen
                  ? _buildInlineSearchBar(surfaceColor, textPrimary)
                  : _buildNormalHeader(surfaceColor, textPrimary),
            ),
          ),
        ),
        body: Column(
          children: [
            // 1. Pinned Black Categories Bar (Matching Android rv_categories)
            _buildCategoriesBar(),

            // 2. Main Scrollable News Feed
            Expanded(
              child: RefreshIndicator(
                color: brandPrimary,
                backgroundColor: surfaceColor,
                onRefresh: _refreshFeed,
                child: _isLoading && _allArticles.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: brandPrimary),
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          // If Home Feed: Render all categorized sections (Latest News, Gujarat, National, etc.)
                          if (isHomeFeed) ...[
                            ..._homeGroups.map(
                              (group) => _buildCategoryGroupSection(
                                group,
                                textPrimary,
                                textSecondary,
                                dividerColor,
                              ),
                            ),
                            // Photo Gallery Section at the bottom of Home Feed
                            _buildPhotoGallerySection(textPrimary, textSecondary),
                          ] else ...[
                            // Specific Category Feed with Hero + Articles
                            // (Videos tab never reaches here — it pushes ShortsFeedScreen)
                            if (_allArticles.isNotEmpty)
                              _buildHeroCard(_allArticles.first, textSecondary),
                            ..._allArticles.skip(1).map(
                              (article) => _buildArticleRow(
                                article,
                                textPrimary,
                                textSecondary,
                                dividerColor,
                              ),
                            ),
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

  // --- Normal Top Bar (Matching Android MaterialToolbar) ---
  Widget _buildNormalHeader(Color surfaceColor, Color textPrimary) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      color: surfaceColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hamburger Menu Button
          IconButton(
            icon: Icon(Icons.menu, color: textPrimary, size: 26),
            tooltip: 'Menu',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),

          const SizedBox(width: 4),

          // Official Gujarat Post Logo (Auto-constrained, No text overflow!)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/gujarat_post_logo.png',
                height: 38,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text(
                  'GUJARAT POST',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: brandPrimary,
                  ),
                ),
              ),
            ),
          ),

          // Search Button
          IconButton(
            icon: Icon(Icons.search, color: textPrimary, size: 24),
            tooltip: 'Search',
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _isSearchOpen = true;
              });
            },
          ),

          // Dark Mode Toggle Button
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: textPrimary,
              size: 22,
            ),
            tooltip: 'Toggle dark mode',
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),

          // Notifications Bell Button
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: textPrimary,
              size: 24,
            ),
            tooltip: 'Notifications',
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints(),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('કોઈ નવી સૂચના નથી (No new notifications)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          // More Options Popup Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textPrimary, size: 24),
            color: surfaceColor,
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshFeed();
              } else if (value == 'saved') {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Text('રિફ્રેશ કરો (Refresh)',
                    style: TextStyle(color: textPrimary)),
              ),
              PopupMenuItem(
                value: 'saved',
                child: Text('સેવ કરેલા સમાચાર (Saved)',
                    style: TextStyle(color: textPrimary)),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('અમારા વિશે (About Us)',
                    style: TextStyle(color: textPrimary)),
              ),
            ],
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // --- Inline Search Bar State (Matching Android layout_search_inline) ---
  Widget _buildInlineSearchBar(Color surfaceColor, Color textPrimary) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: surfaceColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () {
              setState(() {
                _isSearchOpen = false;
                _searchController.clear();
              });
              _refreshFeed();
            },
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'સમાચાર શોધો... (Search news)',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _refreshFeed(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: brandPrimary),
            onPressed: _refreshFeed,
          ),
        ],
      ),
    );
  }

  // --- Pinned Black Categories Bar (Matching Android rv_categories) ---
  Widget _buildCategoriesBar() {
    return Container(
      height: 44,
      width: double.infinity,
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final cat = _categories[index];

          return InkWell(
            onTap: () => _onCategorySelected(index),
            splashColor: Colors.white10,
            highlightColor: Colors.white10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                      fontSize: 15.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2.5,
                    width: isSelected ? 28 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? brandRed : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  // --- Categorized Section Group (Matching Android item_home_category_section.xml) ---
  Widget _buildCategoryGroupSection(
    CategorySectionGroup group,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
  ) {
    final articles = group.articles;
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Section Title Bar: Vertical Indicator Bar + "Latest News" + "View all →"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    final catIdx = _categories
                        .indexWhere((c) => c.slug == group.slug);
                    if (catIdx >= 0) _onCategorySelected(catIdx);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thick vertical indicator bar matching Screenshot 1
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: textPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          group.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  final catIdx = _categories
                      .indexWhere((c) => c.slug == group.slug);
                  if (catIdx >= 0) {
                    _onCategorySelected(catIdx);
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // If Carousel (National / Entertainment): Dedicated white-card carousel matching Reference Image
        if (group.isCarousel)
          _buildHorizontalCardCarousel(group, textPrimary, textSecondary)
        else if (group.isListOnly) ...[
          // Clean List-Only Mode for Fact Check & Technology (No large banner card, clean list only)
          ...articles.take(6).map(
                (article) => _buildArticleRow(
                  article,
                  textPrimary,
                  textSecondary,
                  dividerColor,
                ),
              ),
        ] else ...[
          // Standard Vertical: Featured Hero Card + 5 Sub articles (1 main + 5 below)
          _buildHeroCard(articles.first, textSecondary),
          const SizedBox(height: 4),
          ...articles.skip(1).take(5).map(
                (article) => _buildArticleRow(
                  article,
                  textPrimary,
                  textSecondary,
                  dividerColor,
                ),
              ),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  // --- Horizontal Card Carousel (Matching Reference Image: Aligned 16px start padding, tight 8px gap, side card peeking) ---
  Widget _buildHorizontalCardCarousel(
    CategorySectionGroup group,
    Color textPrimary,
    Color textSecondary,
  ) {
    final articles = group.articles.take(6).toList();
    final isDark = _isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.78).clamp(270.0, 310.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        SizedBox(
          height: 242,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final item = articles[idx];
              return Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openArticleDetail(item),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. News Image at Top (Cover fit, 138px height)
                          SizedBox(
                            height: 138,
                            width: double.infinity,
                            child: Image.network(
                              item.displayImageUrl,
                              fit: BoxFit.cover,
                              headers: const {
                                'User-Agent':
                                    'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImagePlaceholder(),
                            ),
                          ),

                          // 2. Headline & Date / Read Time metadata
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Headline (2 lines max, ellipsis)
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      height: 1.35,
                                      letterSpacing: -0.1,
                                      fontFamily: 'NotoSansGujarati',
                                    ),
                                  ),

                                  // Date and Read Time (e.g. "19 Oct 2026 | 1 min read time")
                                  Text(
                                    '${_formatArticleDate(item)} | ${_calcReadTime(item)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: -0.1,
                                      fontFamily: 'NotoSansGujarati',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatArticleDate(Article article) {
    if (article.publishedAt != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final dt = article.publishedAt!;
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
    if (article.timeAgo.contains('day')) {
      final days = int.tryParse(article.timeAgo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      final dt = DateTime.now().subtract(Duration(days: days));
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } else if (article.timeAgo.contains('hour') ||
        article.timeAgo.contains('minute') ||
        article.timeAgo.contains('now')) {
      final dt = DateTime.now();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
    return article.timeAgo;
  }

  String _calcReadTime(Article article) {
    final text = '${article.title} ${article.excerpt ?? ''} ${article.content ?? ''}'.trim();
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final mins = (words / 150).ceil();
    final readMins = mins < 1 ? 1 : mins;
    return '$readMins min read time';
  }

  // --- Photo Gallery Section (Matching Reference Image: Red "ફોટો ગેલેરી" Pill, Dark Horizontal Line, "વધુ ફોટો ગેલેરી →", Full-Bleed Portrait Cards with Red "સમાચાર" Pill) ---
  Widget _buildPhotoGallerySection(
    Color textPrimary,
    Color textSecondary,
  ) {
    // Select Photo Gallery articles
    List<Article> galleryArticles = _allArticles.where((a) {
      final cat = (a.categorySlug ?? a.category ?? '').toLowerCase();
      final title = a.title.toLowerCase();
      return cat.contains('gallery') ||
          cat.contains('photo') ||
          title.contains('ફોટો') ||
          title.contains('ગેલેરી');
    }).toList();

    if (galleryArticles.isEmpty) {
      galleryArticles = _allArticles.skip(2).take(6).toList();
    }

    final isDark = _isDarkMode;
    final dividerLineColor = isDark ? const Color(0xFF334155) : const Color(0xFF1E293B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Header: Red "ફોટો ગેલેરી" Pill + "વધુ ફોટો ગેલેરી →"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Red "ફોટો ગેલેરી" Pill Badge with subtle glow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB3121B), Color(0xFF8E0E15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB3121B).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'ફોટો ગેલેરી',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansGujarati',
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              // "વધુ ફોટો ગેલેરી →" Link
              InkWell(
                onTap: () {
                  final catIdx = _categories.indexWhere(
                    (c) => c.slug.contains('gallery') || c.slug == 'entertainment',
                  );
                  if (catIdx >= 0) {
                    _onCategorySelected(catIdx);
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'વધુ ફોટો ગેલેરી',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB3121B),
                          fontFamily: 'NotoSansGujarati',
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 15,
                        color: Color(0xFFB3121B),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Accent Line Running Underneath the Badge across the full width
        Container(
          margin: const EdgeInsets.only(top: 6, bottom: 12),
          height: 1.5,
          color: dividerLineColor,
        ),

        // Horizontal Carousel of Photo Cards
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: galleryArticles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final item = galleryArticles[idx];
              const badgeLabel = 'સમાચાર';

              return Container(
                width: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openArticleDetail(item),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          Image.network(
                            item.displayImageUrl,
                            fit: BoxFit.cover,
                            headers: const {
                              'User-Agent':
                                  'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),

                          // Bottom Dark Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.black.withValues(alpha: 0.92),
                                ],
                                stops: const [0.35, 0.55, 0.75, 1.0],
                              ),
                            ),
                          ),

                          // Top-Left Category Badge ("સમાચાર")
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'NotoSansGujarati',
                                ),
                              ),
                            ),
                          ),

                          // Bottom Headline Title
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                                fontFamily: 'NotoSansGujarati',
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // --- Horizontal Carousel Slider (Matching Android HomeCarouselAdapter & rvCarouselArticles) ---
  Widget _buildCarouselSection(
    CategorySectionGroup group,
    Color textSecondary,
  ) {
    final articles = group.articles.take(6).toList();
    final activeIndex = _carouselActiveIndex[group.slug] ?? 0;

    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: articles.length,
            onPageChanged: (pos) {
              setState(() {
                _carouselActiveIndex[group.slug] = pos;
              });
            },
            itemBuilder: (context, idx) {
              final item = articles[idx];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: _buildHeroCard(item, textSecondary, isCarouselItem: true),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // Carousel Dot Indicators (Matching layoutCarouselDots in Android)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(articles.length, (index) {
            final isActive = index == activeIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? brandRed : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- Hero Featured Card (Matching Android item_home_hero.xml) ---
  Widget _buildHeroCard(
    Article article,
    Color textSecondary, {
    bool isCarouselItem = false,
  }) {
    return InkWell(
      onTap: () => _openArticleDetail(article),
      child: Container(
        height: isCarouselItem ? 185 : 210,
        margin: EdgeInsets.symmetric(
          horizontal: isCarouselItem ? 0 : 16,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Cover Image
              Positioned.fill(
                child: Image.network(
                  article.displayImageUrl,
                  fit: BoxFit.cover,
                  headers: const {
                    'User-Agent':
                        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                ),
              ),

              // Bottom Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // Overlaid Title & Date
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.28,
                        letterSpacing: 0.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Article Feed Row (Matching Android item_article_card.xml) ---
  Widget _buildArticleRow(
    Article article,
    Color textPrimary,
    Color textSecondary,
    Color dividerColor,
  ) {
    return InkWell(
      onTap: () => _openArticleDetail(article),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 16:10 Thumbnail with clean rounded corners
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 114,
                    height: 76,
                    color: const Color(0xFFF1F5F9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          article.displayImageUrl,
                          fit: BoxFit.cover,
                          headers: const {
                            'User-Agent':
                                'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(isSmall: true),
                        ),
                        if (_categories[_selectedCategoryIndex].slug == 'videos')
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 34,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Title + Date Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          height: 1.32,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.timeAgo,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 0.8, color: dividerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isSmall = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242B38), Color(0xFF131822)],
        ),
      ),
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.45,
        child: Image.asset(
          'assets/images/gujarat_post_logo.png',
          width: isSmall ? 52 : 90,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.newspaper,
            size: isSmall ? 28 : 42,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }

  // --- Navigation Drawer (Matching Android layout_nav_drawer.xml) ---
  Widget _buildNavigationDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drawer Header: White background, back arrow, official logo
            Container(
              height: 56 + MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 12,
                right: 12,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/gujarat_post_logo.png',
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  ..._categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;
                    final isSelected = _selectedCategoryIndex == index;

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      title: Text(
                        cat.name,
                        style: TextStyle(
                          color: isSelected ? brandRed : Colors.white,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _onCategorySelected(index);
                      },
                    );
                  }),

                  const Divider(color: Color(0xFF27272A), height: 24),

                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.bookmark_outline,
                        color: Colors.white70),
                    title: const Text(
                      'Saved Articles (સાચવેલા સમાચાર)',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('સેવ કરેલા સમાચાર ટૂંક સમયમાં ખૂલશે'),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.video_library_outlined,
                        color: Colors.white70),
                    title: const Text(
                      'Shorts & Videos (વિડિયો)',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _onCategorySelected(1); // Videos tab
                    },
                  ),

                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.settings_outlined,
                        color: Colors.white70),
                    title: const Text(
                      'Settings (સેટિંગ્સ)',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
