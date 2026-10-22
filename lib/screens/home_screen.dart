import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_screen.dart';

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
    if (_selectedCategoryIndex == index) return;
    setState(() {
      _selectedCategoryIndex = index;
    });
    _refreshFeed();
  }

  void _openArticleDetail(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          article: article,
          relatedArticles: _allArticles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF0F1015) : Colors.white;
    final surfaceColor = _isDarkMode ? const Color(0xFF18181B) : Colors.white;
    final textPrimary = _isDarkMode ? const Color(0xFFF1F5F9) : Colors.black;
    final textSecondary =
        _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF808080);
    final dividerColor =
        _isDarkMode ? const Color(0xFF27272A) : const Color(0xFFEEEEEE);

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
                          // Category header when viewing a specific category (e.g. Gujarat, Videos)
                          if (!isHomeFeed)
                            _buildCategoryViewHeader(textPrimary),

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
                          ] else ...[
                            // Specific Category Feed with Hero + Articles
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


  // --- Header when viewing a specific Category (e.g. Gujarat, National) ---
  Widget _buildCategoryViewHeader(Color textPrimary) {
    final catName = _categories[_selectedCategoryIndex].name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () {
              _onCategorySelected(0); // return to Home
            },
          ),
          const SizedBox(width: 4),
          Text(
            catName,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
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
        const SizedBox(height: 8),

        // Section Title Bar: "Title" + "View all ▸"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  final catIdx = _categories
                      .indexWhere((c) => c.slug == group.slug);
                  if (catIdx >= 0) _onCategorySelected(catIdx);
                },
                child: Text(
                  group.title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
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
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_right, size: 20, color: textPrimary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // If Carousel (National / Entertainment as per Android HomeCategoryGroupAdapter)
        if (group.isCarousel)
          _buildCarouselSection(group, textSecondary)
        else ...[
          // Standard Vertical: Featured Hero Card + Sub articles
          _buildHeroCard(articles.first, textSecondary),
          const SizedBox(height: 4),
          ...articles.skip(1).take(3).map(
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
                child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
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
                left: 12,
                right: 12,
                bottom: 10,
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
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        height: 1.28,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12.5,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 16:10 Thumbnail with 8dp rounded corner
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 118,
                    height: 76,
                    color: const Color(0xFFF1F5F9),
                    child: article.imageUrl != null &&
                            article.imageUrl!.isNotEmpty
                        ? Image.network(
                            article.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(isSmall: true),
                          )
                        : _buildImagePlaceholder(isSmall: true),
                  ),
                ),

                const SizedBox(width: 12),

                // Title + Date Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.26,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        article.timeAgo,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
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
            child: Divider(height: 1, thickness: 0.6, color: dividerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isSmall = false}) {
    return Container(
      color: const Color(0xFF2A2E39),
      alignment: Alignment.center,
      child: Icon(
        Icons.newspaper,
        size: isSmall ? 28 : 42,
        color: Colors.white24,
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
