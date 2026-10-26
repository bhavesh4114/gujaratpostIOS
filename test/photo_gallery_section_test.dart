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

  testWidgets('Photo Gallery section renders at the bottom of Home Screen matching reference',
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

    final verticalListFinder = find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.vertical,
    );
    expect(verticalListFinder, findsOneWidget);

    // Scroll to the very bottom to reach Photo Gallery
    await tester.drag(verticalListFinder, const Offset(0, -6000));
    await tester.pumpAndSettle();

    // 1. Verify "ફોટો ગેલેરી" Header Badge exists
    final galleryBadgeFinder = find.text('ફોટો ગેલેરી');
    expect(galleryBadgeFinder, findsOneWidget);

    // 2. Verify "વધુ ફોટો ગેલેરી" link exists
    final seeMoreFinder = find.text('વધુ ફોટો ગેલેરી');
    expect(seeMoreFinder, findsOneWidget);

    // 3. Verify Photo Gallery Cards have "સમાચાર" badge
    final newsBadgeFinder = find.text('સમાચાર');
    expect(newsBadgeFinder, findsWidgets);
  });
}
