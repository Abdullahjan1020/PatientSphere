import 'package:flutter_test/flutter_test.dart';
import 'package:patientsphere/main.dart';

void main() {
  testWidgets('Hospital App Login Screen smoke test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    // We changed MyApp to PatientSphereApp to match your main.dart
    await tester.pumpWidget(const PatientSphereApp());

    // 2. Verify that the Login Screen elements are present.
    // Since our LoginScreen has the text "Hospital Portal"
    expect(find.text('Hospital Portal'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // 3. Verify that the counter '0' (from the old default app) does NOT exist.
    expect(find.text('0'), findsNothing);
  });
}