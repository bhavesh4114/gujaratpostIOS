import 'package:flutter/material.dart';

import '../models/article.dart';
import 'shorts_feed_screen.dart';

class YoutubeVideoScreen extends StatelessWidget {
  final Article article;
  final String videoId;
  final List<Article>? playlist;

  const YoutubeVideoScreen({
    super.key,
    required this.article,
    required this.videoId,
    this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    final list = playlist ?? [article];
    final idx = list.indexWhere((a) => a.id == article.id);

    return ShortsFeedScreen(
      videos: list,
      initialIndex: idx >= 0 ? idx : 0,
    );
  }
}
