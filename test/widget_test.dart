import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:breach/app.dart';

void main() {
  testWidgets('BreachApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BreachApp()),
    );

    // Verify the app builds
    expect(find.byType(BreachApp), findsOneWidget);

    // Drain splash animation timers
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
