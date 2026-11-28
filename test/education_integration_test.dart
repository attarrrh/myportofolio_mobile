import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/screens/education_detail_screen.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';

const entry = Education(
  id: 'server-id',
  institution: 'UI',
  degree: 'Sarjana',
  major: 'Ilmu Komputer',
  graduationYear: 2029,
);
Map<String, dynamic> payload() => {'id': 'server-id', ...entry.toJson()};

void main() {
  test(
    'Education GET is public and POST uses token with server-owned ID omitted',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/education/');
          if (request.method == 'GET') {
            expect(request.headers.containsKey('Authorization'), false);
            return http.Response(jsonEncode([payload()]), 200);
          }
          expect(request.headers['Authorization'], 'Token owner-token');
          final sent = jsonDecode(request.body) as Map<String, dynamic>;
          expect(sent.containsKey('id'), false);
          expect(sent['graduation_year'], 2029);
          return http.Response(jsonEncode(payload()), 201);
        }),
      );
      expect((await api.getEducation()).single.institution, 'UI');
      expect(
        (await api.createEducation(entry, token: 'owner-token')).id,
        'server-id',
      );
    },
  );

  test('Education API surfaces non-success responses', () async {
    for (final status in [400, 401, 403, 500]) {
      final api = ApiClient(
        client: MockClient((_) async => http.Response('error', status)),
      );
      await expectLater(
        api.createEducation(entry, token: 'bad'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'status', status),
        ),
      );
    }
  });

  testWidgets(
    'Public list handles loading, retry, empty, and opens full detail',
    (tester) async {
      final pending = Completer<http.Response>();
      var calls = 0;
      final api = ApiClient(
        client: MockClient((_) async {
          calls++;
          if (calls == 1) return pending.future;
          if (calls == 2) return http.Response('[]', 200);
          return http.Response(jsonEncode([payload()]), 200);
        }),
      );
      await tester.pumpWidget(
        MyApp(apiClient: api, home: const EducationListScreen()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(http.Response('error', 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No education found.'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.text('UI'), findsOneWidget);
      await tester.tap(find.text('UI'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationDetailScreen), findsOneWidget);
      for (final value in [
        'UI',
        'Sarjana',
        'Ilmu Komputer',
        '2029',
        'server-id',
      ]) {
        expect(find.text(value), findsOneWidget);
      }
    },
  );

  testWidgets('Expired token clears session and requests login on submit', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient((_) async => http.Response('expired', 401)),
    );
    await tester.pumpWidget(
      MyApp(
        apiClient: api,
        initialToken: 'expired',
        home: const EducationFormPage(),
      ),
    );
    for (final pair in {
      'Institusi': 'UI',
      'Gelar': 'Sarjana',
      'Program studi': 'Ilmu Komputer',
      'Tahun lulus': '2029',
    }.entries) {
      final field = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == pair.key,
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, pair.value);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
  testWidgets(
    'Guest logs in to add education and saved entry appears in list',
    (tester) async {
      final saved = <Map<String, dynamic>>[];
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/auth/token/')) {
            return http.Response('{"token":"owner"}', 200);
          }
          if (request.method == 'POST') {
            saved.add({
              'id': 'new-id',
              ...jsonDecode(request.body) as Map<String, dynamic>,
            });
            return http.Response(jsonEncode(saved.last), 201);
          }
          return http.Response(jsonEncode(saved), 200);
        }),
      );
      await tester.pumpWidget(MyApp(apiClient: api));
      await tester.ensureVisible(find.text('Tambah Pendidikan'));
      await tester.tap(find.text('Tambah Pendidikan'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      for (final label in ['Username', 'Password']) {
        await tester.enterText(
          find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == label,
          ),
          'owner',
        );
      }
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationFormPage), findsOneWidget);
      for (final pair in {
        'Institusi': 'UI',
        'Gelar': 'Sarjana',
        'Program studi': 'Ilmu Komputer',
        'Tahun lulus': '2029',
      }.entries) {
        final field = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == pair.key,
        );
        await tester.ensureVisible(field);
        await tester.enterText(field, pair.value);
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Pendidikan tersimpan'), findsOneWidget);
      await tester.tap(find.text('Lihat Pendidikan'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationListScreen), findsOneWidget);
      expect(find.text('UI'), findsOneWidget);
    },
  );
}
