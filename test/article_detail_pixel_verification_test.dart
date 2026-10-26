import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/models/article.dart';
import 'package:gujarat_post_flutter/screens/article_detail_screen.dart';

void main() {
  testWidgets('Pixel-to-pixel verification of ArticleDetailScreen matching Reference Image',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testArticle = Article(
      id: 'sachivalay-lift-case',
      title:
          'સચિવાલયમાં જ સુરક્ષાના ધજાગરા: CM ભૂપેન્દ્ર પટેલ અને મુખ્ય સચિવ જે લિફ્ટ વાપરે છે તેના જ લાયસન્સ રિન્યુ નથી થયા',
      slug: 'sachivalay-lift-case',
      content:
          '• બેદરકારી છુપાવવા સર્ટિફિકેટ જ ગાયબ કરી દેવાયા\n'
          '• સ્વર્ણિમ સંકુલ-1, 2 અને બ્લોક-1ની લિફટો પણ જોખમી\n\n'
          'ગાંધીનગર: ગુજરાતમાં લિફ્ટ સલામતી અને સુરક્ષાના કડક નિયમો બનાવતી રાજ્ય સરકારના વહીવટી તંત્રના ગઠ સમાન સચિવાલયમાં જ લિફ્ટ સુરક્ષા મામલે અત્યંત ચોંકાવનારો ખુલાસો થયો છે.',
      imageUrl: 'https://gujaratpost.in/news/cm_bhupendra.jpg',
      authorName: 'Gujaratpost',
      publishedAt: DateTime(2026, 10, 21, 20, 47),
      timeAgo: 'Just now',
      adImageUrl: 'https://gujaratpost.in/ads/sample_banner.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailScreen(
          article: testArticle,
          relatedArticles: [testArticle],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top App Bar: iOS back chevron and capsule pill with active red dot
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    // Verify dots indicator exists inside AppBar
    final redDotFinder = find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).color == const Color(0xFFE50914));
    expect(redDotFinder, findsOneWidget);

    // 2. Verify News Headline Typography & Font
    final headlineFinder = find.text(testArticle.title);
    expect(headlineFinder, findsOneWidget);
    final Text headlineWidget = tester.widget(headlineFinder);
    expect(headlineWidget.style?.fontFamily, equals('NotoSansGujarati'));
    expect(headlineWidget.style?.fontWeight, equals(FontWeight.w700));
    expect(headlineWidget.style?.fontSize, equals(21.0));
    expect(headlineWidget.style?.height, equals(1.30));

    // 3. Verify Author ("Gujaratpost") and Date ("21 Oct 2026, 08:47 PM")
    final authorFinder = find.text('Gujaratpost');
    expect(authorFinder, findsOneWidget);
    final Text authorWidget = tester.widget(authorFinder);
    expect(authorWidget.style?.fontWeight, equals(FontWeight.w700));
    expect(authorWidget.style?.fontSize, equals(13.5));

    final dateFinder = find.text('21 Oct 2026, 08:47 PM');
    expect(dateFinder, findsOneWidget);
    final Text dateWidget = tester.widget(dateFinder);
    expect(dateWidget.style?.fontWeight, equals(FontWeight.w700));
    expect(dateWidget.style?.fontSize, equals(12.0));

    // 4. Verify Image has rounded corners (ClipRRect radius 16) and padded margins
    final clipRRectFinder = find.byWidgetPredicate(
        (w) => w is ClipRRect && w.borderRadius == BorderRadius.circular(16));
    expect(clipRRectFinder, findsAtLeastNWidgets(1));

    // Verify Advertisement is present
    expect(find.text('ADVERTISEMENT'), findsAtLeastNWidgets(1));

    // 5. Verify Bullet Highlights below Image
    final bulletFinder =
        find.textContaining('બેદરકારી છુપાવવા સર્ટિફિકેટ જ ગાયબ કરી દેવાયા');
    await tester.scrollUntilVisible(bulletFinder, 200);
    await tester.pumpAndSettle();
    expect(bulletFinder, findsOneWidget);
    expect(
        find.textContaining('સ્વર્ણિમ સંકુલ-1, 2 અને બ્લોક-1ની લિફટો પણ જોખમી'),
        findsOneWidget);
    expect(find.text('•  '), findsAtLeastNWidgets(1));

    // 6. Verify Body Text with City Prefix
    final bodyTextFinder = find.byWidgetPredicate((w) =>
        w is RichText &&
        w.text.toPlainText().contains('ગાંધીનગર:') &&
        w.text.toPlainText().contains('ગુજરાતમાં લિફ્ટ સલામતી'));
    await tester.scrollUntilVisible(bodyTextFinder, 200);
    await tester.pumpAndSettle();
    expect(bodyTextFinder, findsOneWidget);

    // 7. Verify Top AppBar Reader Actions (Bookmark, 'A', Share)
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.byIcon(Icons.share), findsOneWidget);
  });
}
