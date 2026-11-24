import 'package:flutter_test/flutter_test.dart';
import 'package:platewatch/main.dart';

void main() {
  testWidgets('PlateWatchApp dapat dijalankan', (WidgetTester tester) async {
    await tester.pumpWidget(const PlateWatchApp());

    expect(find.byType(PlateWatchApp), findsOneWidget);
  });
}