import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/project_form.dart';

Finder input(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> fill(WidgetTester tester, String label, String value) async {
  final field = input(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final button = find.widgetWithText(ElevatedButton, 'Save');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  expect(button.hitTestable(), findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> selectCategory(WidgetTester tester, String category) async {
  final dropdown = find.byType(DropdownButtonFormField<String>);
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(category).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Drawer replaces the current page in both directions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('My Portfolio'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
      isFalse,
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(MyHomePage))).canPop(),
      isFalse,
    );
  });

  testWidgets('Required fields reject empty and whitespace-only input', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    await save(tester);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await fill(tester, 'Nama Proyek', '   ');
    await fill(tester, 'Deskripsi Proyek', '   ');
    await save(tester);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Dialog displays all fields and OK resets values and category', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    await fill(tester, 'Nama Proyek', '  Portofolio Attar  ');
    await fill(tester, 'Deskripsi Proyek', 'Aplikasi portofolio pribadi');
    await selectCategory(tester, 'Mobile Development');
    await fill(tester, 'Teknologi yang Digunakan', 'Flutter, Django');
    await fill(tester, 'Tautan Proyek', 'https://example.com/portfolio');
    await save(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Nama Proyek: Portofolio Attar'), findsOneWidget);
    expect(find.text('Deskripsi: Aplikasi portofolio pribadi'), findsOneWidget);
    expect(find.text('Kategori: Mobile Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(find.text('Tautan: https://example.com/portfolio'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    for (final field in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(field.controller.text, isEmpty);
    }
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .value,
      'Web Development',
    );

    await fill(tester, 'Nama Proyek', 'Proyek kedua');
    await fill(tester, 'Deskripsi Proyek', 'Tanpa teknologi dan tautan');
    await save(tester);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: '), findsOneWidget);
    expect(find.text('Tautan: '), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('Form, drawer and dialog fit large text at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: ProjectFormPage(),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.state<ScaffoldState>(find.byType(Scaffold)).closeDrawer();
      await tester.pumpAndSettle();

      await fill(tester, 'Nama Proyek', 'Proyek layar kecil');
      await fill(tester, 'Deskripsi Proyek', 'Deskripsi panjang. ' * 40);
      await selectCategory(tester, 'Machine Learning');
      await save(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
