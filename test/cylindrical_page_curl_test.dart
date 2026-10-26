import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/widgets/cylindrical_page_curl.dart';

Widget _curlHarness() {
  return MaterialApp(
    home: Scaffold(
      body: CylindricalPageCurl(
        itemCount: 3,
        itemBuilder: (context, index) => ColoredBox(
          color: [
            Colors.white,
            Colors.amber.shade100,
            Colors.blue.shade100,
          ][index],
          child: ListView(
            key: ValueKey('article-$index'),
            children: [
              Text('article-$index'),
              SizedBox(height: 1200, child: Center(child: Text('body-$index'))),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void useMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> drag(
    WidgetTester tester,
    Offset from,
    Offset to, {
    Duration duration = const Duration(milliseconds: 220),
  }) async {
    final gesture = await tester.startGesture(from);
    const steps = 6;
    for (var step = 1; step <= steps; step++) {
      final t = step / steps;
      await gesture.moveTo(
        Offset.lerp(from, to, t)!,
        timeStamp: Duration(
          milliseconds: (duration.inMilliseconds * t).round(),
        ),
      );
      await tester.pump(
        Duration(milliseconds: (duration.inMilliseconds / steps).round()),
      );
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('bottom-origin forward and reverse turns reveal adjacent pages', (
    tester,
  ) async {
    useMobileViewport(tester);
    await tester.pumpWidget(_curlHarness());
    await drag(tester, const Offset(350, 790), const Offset(175, 790));
    expect(find.text('article-1'), findsOneWidget);

    await drag(tester, const Offset(35, 790), const Offset(220, 790));
    expect(find.text('article-0'), findsOneWidget);
  });

  testWidgets('top-origin swipe reveals the next page', (tester) async {
    useMobileViewport(tester);
    await tester.pumpWidget(_curlHarness());
    await drag(tester, const Offset(350, 55), const Offset(175, 55));
    expect(find.text('article-1'), findsOneWidget);
  });

  testWidgets('short slow drag cancels and vertical scrolling still works', (
    tester,
  ) async {
    useMobileViewport(tester);
    await tester.pumpWidget(_curlHarness());
    await drag(
      tester,
      const Offset(350, 790),
      const Offset(305, 790),
      duration: const Duration(milliseconds: 500),
    );
    expect(find.text('article-0'), findsOneWidget);

    final body = find.text('body-0');
    expect(body, findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('article-0')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(body).dy, lessThan(500));
  });
}
