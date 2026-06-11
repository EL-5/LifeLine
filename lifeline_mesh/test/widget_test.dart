import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline_mesh/app.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LifelineMeshApp(),
      ),
    );
    expect(find.text('Lifeline Mesh'), findsOneWidget);
  });
}
