import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

ApiClient testApiClient({int createStatus = 201}) => ApiClient(
  baseUrl: 'http://localhost:8000',
  client: MockClient((request) async {
    if (request.url.path == '/api/v1/projects/' && request.method == 'POST') {
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'id': 'new-project-id', ...payload}),
        createStatus,
      );
    }
    if (request.url.path.endsWith('/auth/logout/')) {
      return http.Response('', 204);
    }
    return http.Response('[]', 200);
  }),
);

Finder input(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> fill(WidgetTester tester, String label, String value) async {
  final field = input(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> save(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 300));
  final button = find.widgetWithText(FilledButton, 'Save');
  await tester.ensureVisible(button);
  await tester.pump(const Duration(milliseconds: 100));
  expect(button.hitTestable(), findsOneWidget);
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('Drawer keeps Home and opens Add Project for logged-in user', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: testApiClient(), initialToken: 'valid-token'),
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isTrue,
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Project button opens form and successful POST shows response', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: testApiClient(), initialToken: 'valid-token'),
    );
    final originalMenu = tester.element(find.byType(MyHomePage));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isTrue,
    );

    await fill(tester, 'Title', 'Portfolio project');
    await fill(tester, 'Description', 'A Flutter and Django project');
    await fill(tester, 'Tech stack', 'Flutter, Django');
    await fill(tester, 'Project URL (optional)', 'https://example.com');
    await fill(
      tester,
      'Project Image URL (optional)',
      'https://example.com/image.png',
    );
    await save(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Title: Portfolio project'), findsOneWidget);
    expect(find.text('Tech stack: Flutter, Django'), findsOneWidget);
    expect(find.text('Project URL: https://example.com'), findsOneWidget);
    expect(
      find.text('Image URL: https://example.com/image.png'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(tester.element(find.byType(MyHomePage)), same(originalMenu));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Required fields and URLs are validated before sending', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        apiClient: testApiClient(),
        initialToken: 'valid-token',
        home: const ProjectFormPage(),
      ),
    );
    await save(tester);
    expect(find.text('Title cannot be empty.'), findsOneWidget);
    expect(find.text('Description cannot be empty.'), findsOneWidget);
    expect(find.text('Tech stack cannot be empty.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await fill(tester, 'Title', '   ');
    await fill(tester, 'Description', 'Description');
    await fill(tester, 'Tech stack', 'Django');
    await fill(tester, 'Project URL (optional)', 'javascript:alert(1)');
    await save(tester);
    expect(find.text('Title cannot be empty.'), findsOneWidget);
    expect(find.text('Enter a valid HTTP or HTTPS URL.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('Project form and drawer fit large text at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MyApp(
          apiClient: testApiClient(),
          initialToken: 'valid-token',
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const ProjectFormPage(),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.state<ScaffoldState>(find.byType(Scaffold)).closeDrawer();
      await tester.pumpAndSettle();

      await fill(tester, 'Title', 'Small-screen project');
      await fill(tester, 'Description', 'A long description. ' * 30);
      await fill(tester, 'Tech stack', 'Flutter and Django');
      await save(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
    });
  }
}
