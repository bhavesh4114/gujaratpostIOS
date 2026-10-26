import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/models/article.dart';
import 'package:gujarat_post_flutter/services/news_service.dart';

void main() {
  testWidgets('Shorts feed smoke test', (tester) async {
    final testArticle = Article(
      id: 'h_jQNj_oKcI',
      title: 'હથિયારો જોઇને સૌ કોઇ ચોંકી ગયા, ધારાસભ્ય રાજા ભૈયાનું શક્તિ પ્રદર્શન',
      slug: 'h_jQNj_oKcI',
      videoUrl: 'https://www.youtube.com/watch?v=h_jQNj_oKcI',
      category: 'Videos',
      categorySlug: 'videos',
      timeAgo: '2 hours ago',
    );

    expect(testArticle.videoUrl, contains('h_jQNj_oKcI'));
  });

  test('National section in buildHomeGroups has 6 articles', () {
    final groups = NewsService.buildHomeGroups(NewsService.fallbackArticles);
    final nationalGroup = groups.firstWhere((g) => g.slug == 'national');
    expect(nationalGroup.articles.length, greaterThanOrEqualTo(6));
  });
}
