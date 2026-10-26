import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/models/article.dart';
import 'package:gujarat_post_flutter/screens/article_detail_screen.dart';

void main() {
  testWidgets('ArticleDetailScreen displays Related News without overflow and without floating toolbar', (tester) async {
    // Set a narrow screen size to explicitly test for horizontal overflow prevention
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testArticle = Article(
      id: 'art-1',
      title: 'મુખ્ય સમાચાર શીર્ષક અહીં દર્શાવેલ છે',
      slug: 'main-article',
      content: 'આ પ્રથમ પેરાગ્રાફ છે.\n\nઆ બીજો પેરાગ્રાફ છે.',
      imageUrl: '',
      category: 'National',
      publishedAt: DateTime(2026, 10, 21, 20, 44),
      timeAgo: '2 hours ago',
    );

    final relatedArticle1 = Article(
      id: 'art-2',
      title: 'સંબંધિત સમાચાર ૧: ગુજરાત સરકારનો મોટો નિર્ણય',
      slug: 'rel-1',
      content: 'સંબંધિત સામગ્રી...',
      imageUrl: '',
      category: 'National',
      publishedAt: DateTime(2026, 10, 21, 20, 44),
      timeAgo: '3 hours ago',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailScreen(
          article: testArticle,
          relatedArticles: [testArticle, relatedArticle1],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top AppBar contains 'A' reader settings text button
    expect(find.text('A'), findsOneWidget);

    // 2. Verify old social share section is completely removed
    expect(find.text('Share this article'), findsNothing);
    expect(find.byIcon(Icons.facebook), findsNothing);

    // 3. Scroll to bring Related News into view
    final relatedHeadingFinder = find.text('Related News');
    await tester.scrollUntilVisible(relatedHeadingFinder, 200);
    await tester.pumpAndSettle();

    // 4. Verify Section Heading "Related News" and Document Icon
    expect(relatedHeadingFinder, findsOneWidget);
    expect(find.byIcon(Icons.article_outlined), findsOneWidget);

    // 5. Verify related item content and date format
    expect(find.text('સંબંધિત સમાચાર ૧: ગુજરાત સરકારનો મોટો નિર્ણય'), findsOneWidget);
    expect(find.text('October 21, 20:44'), findsWidgets);
    expect(find.byIcon(Icons.access_time), findsWidgets);

    // No overflow errors occurred during render/layout
    final ex = tester.takeException();
    if (ex != null) {
      if (ex is FlutterError) {
        // ignore: avoid_print
        print('DEBUG OVERFLOW DETAILS:\n${ex.toStringDeep()}');
      } else {
        // ignore: avoid_print
        print('DEBUG OVERFLOW EXCEPTION: $ex');
      }
    }
    expect(ex, isNull);
  });
}
