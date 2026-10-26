import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets('Export National section screenshot', (tester) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'NotoSansGujarati',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: RepaintBoundary(
          key: key,
          child: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final verticalListFinder = find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.vertical,
    );
    // Scroll down so National section is in full view
    await tester.drag(verticalListFinder, const Offset(0, -1120));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final file = File(
          'C:/Users/Bhavesh/.gemini/antigravity-ide/brain/a806ec60-339a-412b-8d22-fb2f081cd526/national_section_screenshot.png');
      await file.writeAsBytes(pngBytes);
    });

    // Scroll down to Entertainment / Life Style section
    await tester.drag(verticalListFinder, const Offset(0, -3200));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final file = File(
          'C:/Users/Bhavesh/.gemini/antigravity-ide/brain/a806ec60-339a-412b-8d22-fb2f081cd526/entertainment_section_screenshot.png');
      await file.writeAsBytes(pngBytes);
    });
  });
}
