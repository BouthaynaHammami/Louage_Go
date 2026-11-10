import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/widgets/premium_nav_bar.dart';

void main() {
  const lastItemKey = ValueKey('last-scroll-item');
  const navItems = [
    PremiumNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    PremiumNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  for (final height in [640.0, 900.0]) {
    testWidgets(
      'last scroll item is above the navigation bar at $height dp in RTL dark mode',
      (tester) async {
        tester.view.physicalSize = Size(390, height);
        tester.view.devicePixelRatio = 1;
        tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewPadding);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: PremiumNavScaffold(
                items: navItems,
                currentIndex: 0,
                onTap: (_) {},
                child: ListView.builder(
                  itemCount: 22,
                  itemBuilder: (context, index) => SizedBox(
                    key: index == 21 ? lastItemKey : null,
                    height: 60,
                    child: Text('Item $index'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(lastItemKey));
        await tester.pumpAndSettle();

        final itemRect = tester.getRect(find.byKey(lastItemKey));
        final navRect = tester.getRect(find.byType(PremiumNavBar));
        expect(itemRect.bottom, lessThanOrEqualTo(navRect.top + 0.1));
        expect(navRect.height, kPremiumNavBarHeight + 24);
      },
    );
  }
}
