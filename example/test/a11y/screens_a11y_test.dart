// Accessibility audit of every component page of the example app
// (flutter_a11y_test, layer "runtime"), on this fork only: dogfood of
// https://github.com/coryj627/flutter-a11y.
//
// Pumps the example's real App (providers, ShadApp, theme) once per route, pushes the
// route on its Navigator and runs the audit battery on the component page. Findings
// are RECORDED, not asserted: the RuntimeFindingsSink in test/flutter_test_config.dart
// writes them to .a11y/flutter/runtime-findings.json and `a11y_check_flutter scan`
// (run at the repository root, so the library's own code is attributed) decides,
// against the committed baseline, what fails CI.
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_a11y_test/flutter_a11y_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _audit(WidgetTester tester, String route) async {
  tester.view.devicePixelRatio = 1.0;
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  tester.view.physicalSize = const Size(1200, 800);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(const App());
  await tester.pump(const Duration(milliseconds: 200));
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  // ignore: unawaited_futures
  navigator.pushNamed(route);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 500));
  final screenId = route.substring(1);
  final result = await auditScreen(tester, screenId: screenId);
  // ignore: avoid_print
  print('a11y $screenId: ${result.findings.length} finding(s)');
  // Take the app down ourselves so that nothing it schedules outlives the test.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  for (final route in routes.keys) {
    testWidgets(route, (tester) async {
      await _audit(tester, route);
    });
  }
}
