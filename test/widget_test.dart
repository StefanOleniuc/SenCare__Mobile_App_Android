// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sencare_app/main.dart';
import 'package:sencare_app/presentation/screen/login_screen.dart';

void main() {
  testWidgets('LoginScreen is shown on app start', (WidgetTester tester) async {
    // 1) În test, punem mereu ProviderScope deasupra SenCareApp
    await tester.pumpWidget(
      const ProviderScope(
        child: SenCareApp(),
      ),
    );

    // 2) Așteptăm să se termine prima frame
    await tester.pumpAndSettle();

    // În mod normal, authTokenProvider este null la start,
    // deci SenCareApp ar trebui să afișeze LoginScreen.

    // Verificăm că există două TextField-uri (Username și Parolă):
    expect(find.byType(TextField), findsNWidgets(2));
    // Verificăm labelText‐urile exacte:
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Parolă'), findsOneWidget);

    // Verificăm și butonul „Loghează-te”:
    expect(find.widgetWithText(ElevatedButton, 'Loghează-te'), findsOneWidget);
  });
}
