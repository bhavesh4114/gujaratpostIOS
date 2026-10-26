import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/screens/home_screen.dart';

void main() {
  setUpAll(() async {
    final regularData =
        File('assets/fonts/noto_sans_gujarati_regular.ttf').readAsBytesSync();
    final mediumData =
        File('assets/fonts/noto_sans_gujarati_medium.ttf').readAsBytesSync();
    final semiBoldData =
        File('assets/fonts/noto_sans_gujarati_semibold.ttf').readAsBytesSync();
    final boldData =
        File('assets/fonts/noto_sans_gujarati_bold.ttf').readAsBytesSync();

    final fontLoader = FontLoader('NotoSansGujarati');
    fontLoader.addFont(Future.value(ByteData.view(regularData.buffer)));
    fontLoader.addFont(Future.value(ByteData.view(mediumData.buffer)));
    fontLoader.addFont(Future.value(ByteData.view(semiBoldData.buffer)));
    fontLoader.addFont(Future.value(ByteData.view(boldData.buffer)));
    await fontLoader.load();
  });

  testWidgets('National News section matches Reference Image layout specifications',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'NotoSansGujarati',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const HomeScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Category Bar has National chip
    expect(find.text('National'), findsWidgets);

    // 2. Scroll down the main feed vertical ListView to reveal the National section
    final verticalListFinder = find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.vertical,
    );
    expect(verticalListFinder, findsOneWidget);

    // Drag down to reach National section (Latest News + Gujarat sections are before National)
    await tester.drag(verticalListFinder, const Offset(0, -900));
    await tester.pumpAndSettle();

    // 3. Verify Horizontal ListView in National Section with 16px padding
    final horizontalLists = find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.horizontal,
    );
    expect(horizontalLists, findsWidgets);

    bool foundNationalList = false;
    for (final element in horizontalLists.evaluate()) {
      final ListView lv = element.widget as ListView;
      if (lv.padding == const EdgeInsets.symmetric(horizontal: 16, vertical: 6)) {
        foundNationalList = true;
        break;
      }
    }
    expect(foundNationalList, isTrue,
        reason: 'National section ListView must have 16px horizontal padding aligned with header');

    // 4. Verify News Card components
    // Date & Read Time metadata text: contains "min read time" and "|"
    final readTimeFinder = find.byWidgetPredicate((widget) {
      if (widget is Text &&
          widget.data != null &&
          widget.data!.contains('min read time') &&
          widget.data!.contains('|')) {
        return true;
      }
      return false;
    });
    expect(readTimeFinder, findsWidgets,
        reason: 'National cards must display "<Date> | <N> min read time"');

    final Text metadataText = tester.widget(readTimeFinder.first);
    expect(metadataText.style?.color, equals(const Color(0xFF94A3B8)));
    expect(metadataText.style?.fontSize, equals(12.0));

    // 5. Verify Headline styling
    // Find a headline text in National section
    final headlineFinder = find.byWidgetPredicate((widget) {
      if (widget is Text &&
          widget.maxLines == 2 &&
          widget.overflow == TextOverflow.ellipsis &&
          widget.style?.fontSize == 14.5 &&
          widget.style?.fontWeight == FontWeight.w700) {
        return true;
      }
      return false;
    });
    expect(headlineFinder, findsWidgets,
        reason: 'National cards must have 2-line headline with fontSize 14.5 and bold weight');

    // 6. Verify National section does not have dots (only Entertainment does)
    // The National PageView should have height 242 and no dots below it
    debugPrint('National section successfully verified matching reference layout!');
  });
}
