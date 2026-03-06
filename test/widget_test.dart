import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:breach/app.dart';

void main() {
  testWidgets('BreachApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BreachApp()),
    );

    // Verify the app builds and the first tab renders
    expect(find.text('BRE4CH'), findsWidgets);
  });
}
