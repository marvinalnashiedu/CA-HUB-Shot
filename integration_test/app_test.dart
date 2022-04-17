import 'package:cahubshot/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Check transition between sign in and sign up screens', (WidgetTester tester) async {
    // Deze test controleert controleert of het registratiescherm verschijnt als er op de Sign up knop wordt gedrukt.
    FirebaseFirestore.instance;

    await tester.pumpWidget(MyApp());

    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);

    await tester.tap(find.text('Sign up'));
    await tester.pump();

    expect(find.text('Sign up'), findsNothing);
    expect(find.text('Log in'), findsOneWidget);
  });
}