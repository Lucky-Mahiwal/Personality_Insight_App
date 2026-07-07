import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_ai/main.dart';
import 'package:astro_ai/models/birth_details.dart';
import 'package:astro_ai/services/astrology_engine.dart';

void main() {
  group('Astrology Engine Unit Tests', () {
    test('Calculates Sun, Moon, and Ascendant positions', () {
      final details = BirthDetails(
        id: 'test_id_1',
        name: 'Friend',
        gender: 'Male',
        dob: DateTime(1995, 6, 15),
        tob: const TimeOfDay(hour: 8, minute: 30),
        place: 'New Delhi, India',
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      final report = AstrologyEngine.generateReport(details);

      // Verify essential properties are calculated
      expect(report.ascendant, isNotEmpty);
      expect(report.moonSign, isNotEmpty);
      expect(report.sunSign, isNotEmpty);
      expect(report.nakshatra, isNotEmpty);
      expect(report.nakshatraLord, isNotEmpty);

      // Verify planets count (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu)
      expect(report.planets.length, equals(9));

      // Verify reports generated
      expect(report.textReports.containsKey('personality'), isTrue);
      expect(report.textReports.containsKey('career'), isTrue);
      expect(report.textReports.containsKey('forecast_2026'), isTrue);
      expect(report.textReports.containsKey('love_marriage'), isTrue);

      // Verify strengths mapping
      final strengths = AstrologyEngine.getElementStrengths(report.planets);
      expect(strengths.containsKey('Fire'), isTrue);
      expect(strengths.containsKey('Water'), isTrue);
      expect(strengths['Fire'], isNotNull);
    });
  });

  testWidgets('AstroApp build and load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AstroApp(firebaseReady: false));

    // Verify splash screen loaded
    expect(find.text('AstraMind'), findsOneWidget);
    expect(find.text('Discover yourself\nthrough your stars'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap "Get Started" — when Firebase is not ready, a SnackBar is shown
    await tester.tap(find.text('Get Started'));
    await tester.pump(); // pump once to trigger the SnackBar

    // Verify the Firebase warning SnackBar appeared
    expect(
      find.text(
        'Firebase is not configured. Run "flutterfire configure" and restart the app.',
      ),
      findsOneWidget,
    );
  });
}
