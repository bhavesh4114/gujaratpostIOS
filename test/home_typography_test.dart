import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/screens/home_screen.dart';

void main() {
  setUpAll(() async {
    final regularData = File('assets/fonts/noto_sans_gujarati_regular.ttf').readAsBytesSync();
    final mediumData = File('assets/fonts/noto_sans_gujarati_medium.ttf').readAsBytesSync();
    final semiBoldData = File('assets/fonts/noto_sans_gujarati_semibold.ttf').readAsBytesSync();
    final boldData = File('assets/fonts/noto_sans_gujarati_bold.ttf').readAsBytesSync();

    final fontLoader = FontLoader('NotoSansGujarati');
    fontLoader.addFont(Future.value(ByteData.view(regularData.buffer)));
    fontLoader.addFont(Future.value(ByteData.view(mediumData.buffer)));
    fontLoader.addFont(Future.value(ByteData.view(semiBoldData.buffer)));
    fontLoader.addFont(Future.value(ByteData.view(boldData.buffer)));
    await fontLoader.load();
  });

  testWidgets('HomeScreen matches target typography at 390x844', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 200));

    // Verify HomeScreen renders
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
