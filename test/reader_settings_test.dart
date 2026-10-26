import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/models/article.dart';
import 'package:gujarat_post_flutter/screens/article_detail_screen.dart';

void main() {
  testWidgets('Reader settings bottom sheet opens and changes font size and theme', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testArticle = Article(
      id: 'art-settings-1',
      title: 'ટેસ્ટ સમાચાર શીર્ષક - રીડર સેટિંગ્સ',
      slug: 'test-settings',
      content: 'અમદાવાદ: આ પ્રથમ ફકરો છે.\n\nઆ બીજો મહત્વપૂર્ણ ફકરો છે.',
      imageUrl: '',
      category: 'ગુજરાત',
      publishedAt: DateTime(2026, 10, 26, 10, 30),
      timeAgo: '1 hour ago',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailScreen(
          article: testArticle,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify "A" icon is in the top AppBar actions
    final fontButtonFinder = find.text('A');
    expect(fontButtonFinder, findsOneWidget);

    // 2. Tap the "A" icon to open the Reader Settings bottom sheet
    await tester.tap(fontButtonFinder);
    await tester.pumpAndSettle();

    // 3. Verify BottomSheet content matches Screenshot 2
    expect(find.text('Select Font Size'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Select Mode'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // 4. Toggle Dark mode
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Check that ReaderPreferences updated to dark mode
    expect(ReaderPreferences.isDarkMode, isTrue);

    // 5. Adjust Font Size via Slider
    final sliderFinder = find.byType(Slider);
    final Slider slider = tester.widget(sliderFinder);
    expect(slider.min, 13.0);
    expect(slider.max, 24.0);
    expect(slider.divisions, 11);

    // Simulate slider change to 20.0
    slider.onChanged?.call(20.0);
    await tester.pumpAndSettle();

    expect(ReaderPreferences.fontSize, 20.0);

    // 6. Toggle back to Light mode
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(ReaderPreferences.isDarkMode, isFalse);
  });
}
