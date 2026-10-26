import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/models/article.dart';
import 'package:gujarat_post_flutter/screens/article_detail_screen.dart';

void main() {
  test('Article model fallback handles empty content by using excerpt', () {
    final jsonWithEmptyContent = {
      'id': 'test-123',
      'titleGu': 'ટેસ્ટ ટાઈટલ',
      'slug': 'test-slug',
      'contentGu': '',
      'excerptGu': 'આ સમાચારનો સારાંશ છે.',
    };

    final article = Article.fromJson(jsonWithEmptyContent);
    expect(article.content, equals('આ સમાચારનો સારાંશ છે.'));
    expect(article.excerpt, equals('આ સમાચારનો સારાંશ છે.'));
  });

  testWidgets('ArticleDetailScreen displays description and middle Blinkit advertisement',
      (WidgetTester tester) async {
    const testArticle = Article(
      id: 'farmer-protest-1',
      title: 'ખડગેએ કહ્યું મોદીનો બાપ પણ જેલમાં જશે',
      slug: 'farmer-protest-1',
      content:
          'ખેડૂત આક્રોશ મહાસભામાં કોંગ્રેસના નેતા તુષાર ચૌધરીએ નિવેદન આપ્યું\n\n'
          'મોરબી: જિલ્લા કોંગ્રેસ સમિતિ દ્વારા રાજપર રોડ ખાતે યોજાયેલી ખેડૂત આક્રોશ મહાસભામાં કોંગ્રેસના નેતાઓએ ભાજપ સરકાર સામે આક્રમક વલણ અપનાવ્યું હતું.\n\n'
          'ડૉ. તુષાર ચૌધરીએ આક્ષેપ કર્યો હતો કે રાજ્યમાં આગામી સમયમાં આવનાર પાણી અને વીજળીના ગંભીર સંકટથી બચવા માટે સરકાર વહેલી ચૂંટણી યોજવાની દિશામાં આગળ વધી રહી છે.',
      timeAgo: 'Just now',
      adImageUrl: 'https://gujaratpost.in/ads/sample_banner.jpg',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailScreen(
          article: testArticle,
          relatedArticles: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify headline is present
    expect(find.text('ખડગેએ કહ્યું મોદીનો બાપ પણ જેલમાં જશે'), findsOneWidget);

    // Verify top advertisement banner above headline
    expect(find.text('ADVERTISEMENT'), findsAtLeastNWidgets(1));

    // Scroll to verify lead highlight / first body paragraph
    final leadFinder = find.textContaining('ખેડૂત આક્રોશ મહાસભામાં કોંગ્રેસના નેતા');
    await tester.scrollUntilVisible(leadFinder, 200);
    await tester.pumpAndSettle();
    expect(leadFinder, findsOneWidget);

    final cityFinder = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains('મોરબી:'),
    );
    await tester.scrollUntilVisible(cityFinder, 200);
    await tester.pumpAndSettle();
    expect(cityFinder, findsOneWidget);

    // Scroll to bring ADVERTISEMENT into view
    final adFinder = find.text('ADVERTISEMENT');
    await tester.scrollUntilVisible(adFinder, 200);
    await tester.pumpAndSettle();

    // Verify middle ADVERTISEMENT label and Blinkit card elements
    expect(adFinder, findsAtLeastNWidgets(1));
    expect(find.text('Blinkit'), findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);

    // Verify second body paragraph following the advertisement
    final secondParaFinder = find.textContaining('ડૉ. તુષાર ચૌધરીએ આક્ષેપ કર્યો');
    await tester.scrollUntilVisible(secondParaFinder, 200);
    await tester.pumpAndSettle();
    expect(secondParaFinder, findsOneWidget);

    // Verify "Share this article" section directly below the article content
    final shareSectionFinder = find.text('Share this article');
    await tester.scrollUntilVisible(shareSectionFinder, 200);
    await tester.pumpAndSettle();
    expect(shareSectionFinder, findsOneWidget);

    // Verify Email button (Icons.mail)
    expect(find.byIcon(Icons.mail), findsOneWidget);

    // Tap WhatsApp button and verify snackbar feedback
    final whatsAppFinder = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.size == const Size(20, 20),
    );
    expect(whatsAppFinder, findsOneWidget);
    await tester.tap(whatsAppFinder);
    await tester.pump();
    expect(find.textContaining('WhatsApp પર'), findsOneWidget);
  });
}
