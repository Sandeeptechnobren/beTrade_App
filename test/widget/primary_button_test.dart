import 'package:betrade/presentation/widget/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper: PrimaryButton uses flutter_screenutil (.h/.sp/.r), so the widget
  // must be pumped inside a ScreenUtilInit with a design size.
  Widget host(Widget child) => ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
        child: child,
      );

  testWidgets('renders its label', (tester) async {
    await tester.pumpWidget(
      host(PrimaryButton(text: 'Confirm Buy', onTap: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirm Buy'), findsOneWidget);
  });

  testWidgets('fires onTap when pressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(PrimaryButton(text: 'Confirm Buy', onTap: () => taps++)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 1);
  });
}
