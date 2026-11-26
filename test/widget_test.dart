import 'package:flutter_test/flutter_test.dart';
import 'package:dept_org_portal/main.dart';

void main() {
  testWidgets('App loads Dept Org Portal', (WidgetTester tester) async {
    await tester.pumpWidget(const DeptOrgPortalApp());
    expect(find.text('Dept Org Portal'), findsOneWidget);
  });
}