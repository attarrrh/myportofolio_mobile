import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

Finder loginField(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

void main() {
  testWidgets('Guard opens Login and then continues to Add Project', (
    tester,
  ) async {
    final paths = <String>[];
    final client = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        paths.add(request.url.path);
        if (request.url.path.endsWith('/auth/token/')) {
          expect(jsonDecode(request.body), {
            'username': 'attar',
            'password': 'password',
          });
          return http.Response(jsonEncode({'token': 'logged-in-token'}), 200);
        }
        return http.Response('[]', 200);
      }),
    );
    await tester.pumpWidget(MyApp(apiClient: client));

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);

    await tester.enterText(loginField('Username'), 'attar');
    await tester.enterText(loginField('Password'), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(paths, contains('/api/v1/auth/token/'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Failed login shows a status message and stays on Login', (
    tester,
  ) async {
    final client = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient(
        (_) async => http.Response('Invalid credentials', 400),
      ),
    );
    await tester.pumpWidget(MyApp(apiClient: client));
    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await tester.enterText(loginField('Username'), 'wrong');
    await tester.enterText(loginField('Password'), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login failed (HTTP 400).'), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Logout clears local token even when server revocation fails', () async {
    final client = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient((_) async => http.Response('Unauthorized', 401)),
    );
    final auth = AuthState(client, initialToken: 'expired-token');
    var notifications = 0;
    auth.addListener(() => notifications++);

    await expectLater(auth.logout(), throwsA(isA<ApiException>()));
    expect(auth.token, isNull);
    expect(auth.isLoggedIn, isFalse);
    expect(notifications, 1);
    client.close();
  });
}
