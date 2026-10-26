import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/screens/home_screen.dart';
import 'package:gujarat_post_flutter/screens/shorts_feed_screen.dart';
import 'package:gujarat_post_flutter/widgets/curved_back_arrow_icon.dart';

void main() {
  test('Curved back arrow path verification', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 165, 128));
    const painter = CurvedBackArrowPainter(color: Colors.white);
    painter.paint(canvas, const Size(165, 128));

    final picture = recorder.endRecording();
    final img = await picture.toImage(165, 128);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    expect(byteData, isNotNull);

    final file = File(r'C:\Users\Bhavesh\.gemini\antigravity-ide\brain\58d74d38-8098-43a9-ab3a-f7aae2fec41e\scratch\flutter_rendered_icon.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());
    expect(file.existsSync(), isTrue);
  });

  testWidgets('ShortsFeedScreen back button renders CurvedBackArrowIcon, has >=48x48 touch target, and redirects to HomeScreen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShortsFeedScreen(videos: []),
      ),
    );

    // Verify CurvedBackArrowIcon is in the widget tree
    final iconFinder = find.byType(CurvedBackArrowIcon);
    expect(iconFinder, findsOneWidget);

    // Verify IconButton exists and has >= 48x48 size
    final buttonFinder = find.byType(IconButton);
    expect(buttonFinder, findsOneWidget);
    final buttonSize = tester.getSize(buttonFinder);
    expect(buttonSize.width, greaterThanOrEqualTo(48.0));
    expect(buttonSize.height, greaterThanOrEqualTo(48.0));

    // Tap the back button
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Verify HomeScreen is now the active route
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
