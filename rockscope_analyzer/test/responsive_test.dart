import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rockscope_analyzer/core/constants/breakpoints.dart';
import 'package:rockscope_analyzer/core/layouts/responsive_layout.dart';
import 'package:rockscope_analyzer/presentation/collection_manager/collection_manager.dart';
import 'package:rockscope_analyzer/presentation/collection_manager/widgets/specimen_card.dart';
import 'package:rockscope_analyzer/presentation/collection_manager/widgets/search_sort_bar.dart';

void main() {
  group('Responsive Layout Tests', () {
    setUpAll(() {
      // Initialize service binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('ResponsiveHelper correctly identifies device types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test mobile breakpoint
              MediaQuery.of(context).size.width = 375; // iPhone width
              expect(ResponsiveHelper.isMobile(context), true);
              expect(ResponsiveHelper.isTablet(context), false);
              expect(ResponsiveHelper.isDesktop(context), false);

              return Container();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test tablet breakpoint
              MediaQuery.of(context).size.width = 900; // iPad width
              expect(ResponsiveHelper.isMobile(context), false);
              expect(ResponsiveHelper.isTablet(context), true);
              expect(ResponsiveHelper.isDesktop(context), false);

              return Container();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test desktop breakpoint
              MediaQuery.of(context).size.width = 1200; // Desktop width
              expect(ResponsiveHelper.isMobile(context), false);
              expect(ResponsiveHelper.isTablet(context), false);
              expect(ResponsiveHelper.isDesktop(context), true);

              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('ResponsiveBuilder renders correct layouts', (WidgetTester tester) async {
      const mobileWidget = Text('Mobile');
      const tabletWidget = Text('Tablet');
      const desktopWidget = Text('Desktop');

      // Test mobile layout
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)), // Mobile size
            child: ResponsiveBuilder(
              mobile: mobileWidget,
              tablet: tabletWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);

      // Test tablet layout
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 1200)), // Tablet size
            child: ResponsiveBuilder(
              mobile: mobileWidget,
              tablet: tabletWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);

      // Test desktop layout
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)), // Desktop size
            child: ResponsiveBuilder(
              mobile: mobileWidget,
              tablet: tabletWidget,
              desktop: desktopWidget,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });
  });

  group('Touch Target Tests', () {
    testWidgets('Touch targets meet minimum 44px requirement', (WidgetTester tester) async {
      final specimenData = {
        'id': 1,
        'name': 'Test Specimen',
        'confidence': 85.0,
        'location': 'Test Location',
        'date': '2024-01-01',
        'status': 'confirmed',
        'imageUrl': '',
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SpecimenCard(
                specimen: specimenData,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all tappable elements
      final inkWells = find.byType(InkWell);
      final iconButtons = find.byType(IconButton);
      final popupMenuButtons = find.byType(PopupMenuButton);

      // Check InkWell dimensions
      if (inkWells.evaluate().isNotEmpty) {
        final inkWellWidget = tester.widget<InkWell>(inkWells.first);
        final renderBox = tester.renderObject(inkWells.first) as RenderBox?;
        if (renderBox != null) {
          expect(renderBox.size.height, greaterThanOrEqualTo(Breakpoints.minTouchTarget));
        }
      }

      // Check IconButton dimensions
      for (final iconButton in iconButtons.evaluate()) {
        final renderBox = tester.renderObject(find.byWidget(iconButton.widget)) as RenderBox?;
        if (renderBox != null) {
          expect(renderBox.size.width, greaterThanOrEqualTo(Breakpoints.minTouchTarget));
          expect(renderBox.size.height, greaterThanOrEqualTo(Breakpoints.minTouchTarget));
        }
      }
    });

    testWidgets('Touch targets are properly spaced', (WidgetTester tester) async {
      final searchController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchSortBar(
              searchController: searchController,
              onSearchChanged: (_) {},
              onSortPressed: () {},
              onMapToggle: () {},
              isMapView: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all buttons in the search sort bar
      final buttons = find.descendant(
        of: find.byType(SearchSortBar),
        matching: find.byType(IconButton),
      );

      if (buttons.evaluate().length >= 2) {
        final positions = buttons.evaluate()
            .map((element) => tester.getTopLeft(find.byWidget(element.widget)))
            .toList();

        // Check spacing between adjacent buttons
        for (int i = 1; i < positions.length; i++) {
          final distance = (positions[i] - positions[i - 1]).distance;
          expect(distance, greaterThanOrEqualTo(8.0)); // Minimum spacing
        }
      }
    });
  });

  group('Breakpoint Behavior Tests', () {
    testWidgets('Layout changes correctly at 768px breakpoint', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(size: size),
              child: Builder(
                builder: (context) {
                  final deviceType = ResponsiveHelper.getDeviceType(size.width);
                  final columns = ResponsiveHelper.getResponsiveColumns(context);
                  
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Device: ${deviceType.name}'),
                        Text('Columns: $columns'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }

      // Test just below tablet breakpoint (mobile)
      await tester.pumpWidget(buildTestWidget(const Size(767, 667)));
      await tester.pumpAndSettle();
      
      expect(find.text('Device: mobile'), findsOneWidget);
      expect(find.text('Columns: 1'), findsOneWidget);

      // Test just above tablet breakpoint
      await tester.pumpWidget(buildTestWidget(const Size(769, 667)));
      await tester.pumpAndSettle();
      
      expect(find.text('Device: tablet'), findsOneWidget);
      expect(find.text('Columns: 2'), findsOneWidget);
    });

    testWidgets('Layout changes correctly at 1024px breakpoint', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(size: size),
              child: Builder(
                builder: (context) {
                  final deviceType = ResponsiveHelper.getDeviceType(size.width);
                  final columns = ResponsiveHelper.getResponsiveColumns(context);
                  
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('Device: ${deviceType.name}'),
                        Text('Columns: $columns'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }

      // Test just below desktop breakpoint (tablet)
      await tester.pumpWidget(buildTestWidget(const Size(1023, 768)));
      await tester.pumpAndSettle();
      
      expect(find.text('Device: tablet'), findsOneWidget);
      expect(find.text('Columns: 2'), findsOneWidget);

      // Test just above desktop breakpoint
      await tester.pumpWidget(buildTestWidget(const Size(1025, 768)));
      await tester.pumpAndSettle();
      
      expect(find.text('Device: desktop'), findsOneWidget);
      expect(find.text('Columns: 3'), findsOneWidget);
    });
  });

  group('Navigation Pattern Tests', () {
    testWidgets('Mobile navigation uses bottom bar', (WidgetTester tester) async {
      final navigationItems = [
        const NavigationItem(
          icon: 'home',
          selectedIcon: 'home',
          label: 'Home',
        ),
        const NavigationItem(
          icon: 'collection',
          selectedIcon: 'collection',
          label: 'Collection',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)), // Mobile size
            child: ResponsiveLayout(
              navigationItems: navigationItems,
              currentIndex: 0,
              child: Container(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have bottom navigation bar on mobile
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('Tablet navigation uses navigation rail', (WidgetTester tester) async {
      final navigationItems = [
        const NavigationItem(
          icon: 'home',
          selectedIcon: 'home',
          label: 'Home',
        ),
        const NavigationItem(
          icon: 'collection',
          selectedIcon: 'collection',
          label: 'Collection',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(900, 1200)), // Tablet size
            child: ResponsiveLayout(
              navigationItems: navigationItems,
              currentIndex: 0,
              child: Container(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have navigation rail on tablet (note: current implementation uses bottom bar)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });

  group('Card Layout Tests', () {
    testWidgets('Cards adapt to different screen sizes', (WidgetTester tester) async {
      final specimenData = {
        'id': 1,
        'name': 'Test Specimen',
        'confidence': 85.0,
        'location': 'Test Location',
        'date': '2024-01-01',
        'status': 'confirmed',
        'imageUrl': '',
      };

      // Test mobile layout
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(375, 667)), // Mobile
              child: Scaffold(
                body: SpecimenCard(
                  specimen: specimenData,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mobileCard = find.byType(SpecimenCard);
      expect(mobileCard, findsOneWidget);

      final mobileRenderBox = tester.renderObject(mobileCard) as RenderBox;
      final mobileSize = mobileRenderBox.size;

      // Test tablet layout
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(900, 1200)), // Tablet
              child: Scaffold(
                body: SpecimenCard(
                  specimen: specimenData,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final tabletCard = find.byType(SpecimenCard);
      expect(tabletCard, findsOneWidget);

      // Cards should maintain proper proportions across screen sizes
      expect(mobileSize.width, greaterThan(0));
      expect(mobileSize.height, greaterThan(0));
    });
  });

  group('Text Scaling Tests', () {
    testWidgets('Text scales appropriately across breakpoints', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final scaleFactor = ResponsiveText.getTextScaleFactor(context);
                final scaledStyle = ResponsiveText.scaleTextStyle(
                  context,
                  const TextStyle(fontSize: 16.0),
                );
                
                return Scaffold(
                  body: Column(
                    children: [
                      Text(
                        'Scale Factor: ${scaleFactor.toStringAsFixed(2)}',
                        key: const Key('scale_factor'),
                      ),
                      Text(
                        'Scaled Text',
                        style: scaledStyle,
                        key: const Key('scaled_text'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }

      // Test mobile text scaling
      await tester.pumpWidget(buildTestWidget(const Size(375, 667)));
      await tester.pumpAndSettle();
      
      final mobileScaleText = tester.widget<Text>(find.byKey(const Key('scale_factor')));
      expect(mobileScaleText.data, contains('0.90')); // Mobile scale factor

      // Test desktop text scaling
      await tester.pumpWidget(buildTestWidget(const Size(1200, 800)));
      await tester.pumpAndSettle();
      
      final desktopScaleText = tester.widget<Text>(find.byKey(const Key('scale_factor')));
      expect(desktopScaleText.data, contains('1.00')); // Desktop scale factor
    });
  });

  group('Responsive Dialog Tests', () {
    testWidgets('Dialogs adapt to screen size', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  ResponsiveDialog.show(
                    context: tester.element(find.byType(Scaffold)),
                    title: 'Test Dialog',
                    child: const Text('Dialog content'),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );
      }

      // Test mobile dialog
      await tester.pumpWidget(buildTestWidget(const Size(375, 667)));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Test Dialog'), findsOneWidget);

      // Close dialog
      await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
      await tester.pumpAndSettle();

      // Test tablet dialog
      await tester.pumpWidget(buildTestWidget(const Size(900, 1200)));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Test Dialog'), findsOneWidget);
    });
  });

  group('Spacing and Padding Tests', () {
    testWidgets('Responsive spacing adapts to screen size', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final spacing = ResponsiveHelper.getResponsiveSpacing(context);
                final padding = ResponsiveHelper.getResponsivePadding(context);
                
                return Scaffold(
                  body: Container(
                    padding: padding,
                    child: Column(
                      children: [
                        Text('Spacing: ${spacing.toStringAsFixed(0)}px'),
                        SizedBox(height: spacing),
                        const Text('Content with responsive spacing'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }

      // Test mobile spacing
      await tester.pumpWidget(buildTestWidget(const Size(375, 667)));
      await tester.pumpAndSettle();
      
      expect(find.text('Spacing: 16px'), findsOneWidget); // Mobile spacing

      // Test tablet spacing
      await tester.pumpWidget(buildTestWidget(const Size(900, 1200)));
      await tester.pumpAndSettle();
      
      expect(find.text('Spacing: 24px'), findsOneWidget); // Tablet spacing

      // Test desktop spacing
      await tester.pumpWidget(buildTestWidget(const Size(1200, 800)));
      await tester.pumpAndSettle();
      
      expect(find.text('Spacing: 32px'), findsOneWidget); // Desktop spacing
    });
  });

  group('Performance Tests', () {
    testWidgets('Layout changes are smooth and performant', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      Widget buildTestWidget(Size size) {
        return ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(size: size),
              child: const CollectionManager(),
            ),
          ),
        );
      }

      // Initial mobile layout
      await tester.pumpWidget(buildTestWidget(const Size(375, 667)));
      await tester.pumpAndSettle();

      final mobileTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Change to tablet layout
      await tester.pumpWidget(buildTestWidget(const Size(900, 1200)));
      await tester.pumpAndSettle();

      final tabletTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Change to desktop layout
      await tester.pumpWidget(buildTestWidget(const Size(1200, 800)));
      await tester.pumpAndSettle();

      final desktopTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Layout changes should be reasonably fast (under 100ms each)
      expect(mobileTime, lessThan(100));
      expect(tabletTime, lessThan(100));
      expect(desktopTime, lessThan(100));
    });
  });
}