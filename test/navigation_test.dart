import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

Future<void> choose(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Drawer preserves Home and does not stack duplicate destinations',
    (tester) async {
      await tester.pumpWidget(
        MyApp(
          initialToken: 'test-token',
          apiClient: ApiClient(
            client: MockClient((_) async => http.Response('[]', 200)),
          ),
        ),
      );
      await choose(tester, 'View Projects');
      expect(find.byType(ProjectListScreen), findsOneWidget);
      await choose(tester, 'Home');
      expect(find.byType(MyHomePage), findsOneWidget);
      await choose(tester, 'View Projects');
      await choose(tester, 'Add Project');
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await choose(tester, 'Add Project');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
