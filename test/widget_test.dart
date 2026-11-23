import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

Future<void> backToMenu(WidgetTester tester) async {
  expect(find.byType(ProjectFormPage), findsOneWidget);
  expect(
    Navigator.of(tester.element(find.byType(ProjectFormPage))).canPop(),
    isTrue,
  );
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(find.byType(ProjectFormPage), findsNothing);
  expect(find.byType(MyHomePage), findsOneWidget);
}

void main() {
  testWidgets('Menu identity and all action messages', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('2506656495'), findsOneWidget);
    expect(find.text('Attar Rais Hakam'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.byType(ItemCard), findsNWidgets(4));

    for (final action in [
      'Lihat Proyek',
      'Tambah Proyek',
      'Tambah Pendidikan',
      'Logout',
    ]) {
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      if (action == 'Tambah Proyek' || action == 'Tambah Pendidikan') {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
      }
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Menu fits a phone and scrolls on short screens', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    await backToMenu(tester);

    tester.view.physicalSize = const Size(640, 320);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(960, 640)]) {
    testWidgets('Menu supports large text at ${size.width} pixels', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const MyHomePage(),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Attar Rais Hakam'), findsOneWidget);

      for (final action in [
        'Lihat Proyek',
        'Tambah Proyek',
        'Tambah Pendidikan',
        'Logout',
      ]) {
        await tester.ensureVisible(find.text(action));
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (action == 'Tambah Proyek' || action == 'Tambah Pendidikan') {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(MyHomePage), findsOneWidget);
        }
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
    });
  }
}
