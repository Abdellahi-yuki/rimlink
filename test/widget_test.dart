import 'package:flutter_test/flutter_test.dart';
import 'package:rimlink/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RimlinkApp());

    // Verify that the login page elements appear.
    expect(find.text('RimLink'), findsWidgets);
  });
}
