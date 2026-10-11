import 'package:flutter_test/flutter_test.dart';

import 'package:urbaneye_mobile/main.dart';

void main() {
  testWidgets('UrbanEye app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const UrbanEyeApp());

    expect(find.text('Welcome to UrbanEye'), findsOneWidget);
  });
}