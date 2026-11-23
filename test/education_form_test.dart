import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> enter(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(field(label));
  await tester.enterText(field(label), value);
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final button = find.widgetWithText(FilledButton, 'Simpan');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> fillEducation(WidgetTester tester) async {
  await enter(tester, 'Institusi', 'Universitas Indonesia');
  await enter(tester, 'Gelar', 'Sarjana');
  await enter(tester, 'Program studi', 'Ilmu Komputer');
  await enter(tester, 'Tahun lulus', '2027');
}

void main() {
  testWidgets('Education card opens the form and Back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Pendidikan'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(EducationFormPage))).canPop(),
      isTrue,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer opens education and Home returns to the main page', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Add Education'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(EducationFormPage))).canPop(),
      isFalse,
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(EducationFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Required fields and graduation year are validated', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await submit(tester);
    expect(find.text('Institusi wajib diisi.'), findsOneWidget);
    expect(find.text('Gelar wajib diisi.'), findsOneWidget);
    expect(find.text('Program studi wajib diisi.'), findsOneWidget);
    expect(find.text('Tahun lulus wajib diisi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await enter(tester, 'Institusi', '   ');
    await enter(tester, 'Gelar', 'Sarjana');
    await enter(tester, 'Program studi', 'Ilmu Komputer');
    await enter(tester, 'Tahun lulus', 'abc');
    await submit(tester);
    expect(find.text('Institusi wajib diisi.'), findsOneWidget);
    expect(find.text('Masukkan tahun yang valid.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Valid form shows all education details in summary dialog', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await fillEducation(tester);
    await submit(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Institusi: Universitas Indonesia'), findsOneWidget);
    expect(find.text('Gelar: Sarjana'), findsOneWidget);
    expect(find.text('Program studi: Ilmu Komputer'), findsOneWidget);
    expect(find.text('Tahun lulus: 2027'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Education form scrolls on a narrow phone screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await fillEducation(tester);
    await submit(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
