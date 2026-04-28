import 'package:flutter_test/flutter_test.dart';

import 'package:first/main.dart';

void main() {
  testWidgets('app starts with splash screen', (WidgetTester tester) async {
    main();
    await tester.pump();

    expect(find.text('Currency Compass'), findsOneWidget);
  });
}
