import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../models/article.dart';
import '../widgets/curved_back_arrow_icon.dart';
import 'home_screen.dart';

/// Full-screen vertical Shorts/Reels player.
///
/// Layout (matching Android ShortsFeedActivity):
///   • Entire screen = video (black background)
///   • ↺ custom curved back arrow overlaid at top-left (SafeArea)
///   • No separate header bar — info overlay is handled by the YouTube embed itself
///   • Swipe up/down → next / previous video
///   • Video autoplays when page becomes active (no tap required)
class ShortsFeedScreen extends StatefulWidget {
  final List<Article> videos;
  final int initialIndex;

  const ShortsFeedScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.videos.isEmpty ? 0 : widget.videos.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);

    // Transparent status bar so video fills top edge
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  static String? extractYoutubeId(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final str = value.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(str)) return str;
    final uri = Uri.tryParse(str);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host == 'youtu.be' || host == 'www.youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (host.contains('youtube.com')) {
      if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v'];
      final segs = uri.pathSegments;
      if (segs.length >= 2 && {'shorts', 'embed', 'live', 'v'}.contains(segs.first)) {
        return segs[1];
      }
    }
    return null;
  }

  void _navigateHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _navigateHome(context);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                  child: IconButton(
                    icon: const CurvedBackArrowIcon(
                      width: 26.0,
                      color: Colors.white,
                    ),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    splashRadius: 24,
                    tooltip: 'Back',
                    onPressed: () => _navigateHome(context),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('કોઈ વિડિયો ઉપલબ્ધ નથી',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateHome(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button (↺ redirects directly to Home page) ───────────
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                child: IconButton(
                  icon: const CurvedBackArrowIcon(
                    width: 26.0,
                    color: Colors.white,
                  ),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  splashRadius: 24,
                  tooltip: 'Back',
                  onPressed: () => _navigateHome(context),
                ),
              ),

            // ── Vertical Shorts/Reels PageView ──────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: widget.videos.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final video = widget.videos[index];
                  final yId = extractYoutubeId(video.videoUrl) ??
                      extractYoutubeId(video.id) ??
                      extractYoutubeId(video.slug);
                  return _ShortsVideoPageItem(
                    key: ValueKey('short_${video.id}_$index'),
                    video: video,
                    youtubeId: yId,
                    isActive: index == _currentIndex,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual video page — fills its entire slot in the PageView
// ─────────────────────────────────────────────────────────────────────────────

class _ShortsVideoPageItem extends StatefulWidget {
  final Article video;
  final String? youtubeId;
  final bool isActive;

  const _ShortsVideoPageItem({
    super.key,
    required this.video,
    required this.youtubeId,
    required this.isActive,
  });

  @override
  State<_ShortsVideoPageItem> createState() => _ShortsVideoPageItemState();
}

class _ShortsVideoPageItemState extends State<_ShortsVideoPageItem> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _initController();
    }
  }

  void _initController() {
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
      ));

    // On Android, allow media autoplay without requiring a user-gesture tap
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      (ctrl.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = ctrl;
    _isInitialized = true;

    if (widget.isActive) _loadVideo();
  }

  void _loadVideo() {
    if (_controller == null || widget.youtubeId == null) return;
    final yId = widget.youtubeId!;

    // autoplay=1 + mute=0; enablejsapi for programmatic control
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    html, body { width:100vw; height:100vh; background:#000; overflow:hidden; }
    iframe { width:100%; height:100%; border:none; display:block; }
  </style>
</head>
<body>
  <iframe
    src="https://www.youtube.com/embed/$yId?autoplay=1&mute=0&playsinline=1&loop=1&playlist=$yId&controls=1&rel=0&modestbranding=1&enablejsapi=1"
    allow="autoplay; encrypted-media; fullscreen; picture-in-picture"
    allowfullscreen>
  </iframe>
</body>
</html>''';

    _controller!.loadHtmlString(html, baseUrl: 'https://gujaratpost.in');
  }

  void _pauseVideo() {
    // Load a blank page to stop audio/video when swiped away
    _controller?.loadHtmlString(
      '<html><body style="margin:0;background:#000"></body></html>',
    );
    if (mounted) setState(() => _isLoading = true);
  }

  @override
  void didUpdateWidget(covariant _ShortsVideoPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized) {
      if (widget.isActive && !oldWidget.isActive) {
        _loadVideo();
      } else if (!widget.isActive && oldWidget.isActive) {
        _pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No YouTube ID → title placeholder
    if (widget.youtubeId == null || widget.youtubeId!.isEmpty) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          widget.video.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    // Non-mobile / test fallback
    if (_controller == null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 72),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.video.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
