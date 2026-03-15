import 'package:flutter_test/flutter_test.dart';
import 'package:edusarthi_app/main.dart';

void main() {
  testWidgets('EduSarthi app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EduSarthiApp());
    expect(find.text('EduSarthi'), findsOneWidget);
  });
}
