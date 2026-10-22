import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gujarat_post_flutter/main.dart';
import 'package:gujarat_post_flutter/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GujaratPostApp());

    // Verify SplashScreen is present
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(RichText), findsWidgets);
    expect(find.byType(Image), findsOneWidget);

    // Let animation and timer complete
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
  });
}
