import 'dart:math';
import 'package:flutter/material.dart';
import '../models/birth_details.dart';
import '../services/astrology_engine.dart';

enum ChartStyle { northIndian, southIndian }

class KundliChart extends StatefulWidget {
  final AstroReport report;
  final ChartStyle initialStyle;

  const KundliChart({
    super.key,
    required this.report,
    this.initialStyle = ChartStyle.northIndian,
  });

  @override
  State<KundliChart> createState() => _KundliChartState();
}

class _KundliChartState extends State<KundliChart> {
  late ChartStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.initialStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chart Style Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStyle = ChartStyle.northIndian;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStyle == ChartStyle.northIndian
                    ? const Color(0xFFFFD700)
                    : Colors.grey[850],
                foregroundColor: _currentStyle == ChartStyle.northIndian
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('North Indian'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStyle = ChartStyle.southIndian;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStyle == ChartStyle.southIndian
                    ? const Color(0xFFFFD700)
                    : Colors.grey[850],
                foregroundColor: _currentStyle == ChartStyle.southIndian
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('South Indian'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Chart Container
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.03),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: _currentStyle == ChartStyle.northIndian
                ? CustomPaint(
                    painter: NorthIndianChartPainter(report: widget.report),
                  )
                : CustomPaint(
                    painter: SouthIndianChartPainter(report: widget.report),
                  ),
          ),
        ),
      ],
    );
  }
}

class NorthIndianChartPainter extends CustomPainter {
  final AstroReport report;

  NorthIndianChartPainter({required this.report});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paint configuration
    final linePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFA500).withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // 1. Draw Board Lines
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close()
      // Diagonals
      ..moveTo(0, 0)
      ..lineTo(w, h)
      ..moveTo(w, 0)
      ..lineTo(0, h)
      // Inner Diamond
      ..moveTo(w / 2, 0)
      ..lineTo(0, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(w, h / 2)
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // 2. Map Lagna sign index (1-based: Aries=1, Taurus=2, etc.)
    final int lagnaSignIdx = AstrologyEngine.zodiacSigns.indexOf(report.ascendant) + 1;

    // Houses relative positions for texts
    // Center point coordinates for each house (1 to 12)
    final houseCenters = {
      1: Offset(w / 2, h / 4),
      2: Offset(w / 3.2, h / 7.5),
      3: Offset(w / 7.5, w / 3.2),
      4: Offset(w / 4, h / 2),
      5: Offset(w / 7.5, h - h / 3.2),
      6: Offset(w / 3.2, h - h / 7.5),
      7: Offset(w / 2, h - h / 4),
      8: Offset(w - w / 3.2, h - h / 7.5),
      9: Offset(w - w / 7.5, h - h / 3.2),
      10: Offset(w - w / 4, h / 2),
      11: Offset(w - w / 7.5, h / 3.2),
      12: Offset(w - w / 3.2, h / 7.5),
    };

    // Label coordinates offsets (drawing the zodiac sign number in each house)
    final signOffsets = {
      1: Offset(w / 2, h / 3.2),
      2: Offset(w / 3.2, h / 4.2),
      3: Offset(w / 4.2, h / 3.2),
      4: Offset(w / 3.2, h / 2),
      5: Offset(w / 4.2, h - h / 3.2),
      6: Offset(w / 3.2, h - h / 4.2),
      7: Offset(w / 2, h - h / 3.2),
      8: Offset(w - w / 3.2, h - h / 4.2),
      9: Offset(w - w / 4.2, h - h / 3.2),
      10: Offset(w - w / 3.2, h / 2),
      11: Offset(w - w / 4.2, h / 3.2),
      12: Offset(w - w / 3.2, h / 4.2),
    };

    // 3. Draw Sign Numbers
    for (int house = 1; house <= 12; house++) {
      final signNumber = (lagnaSignIdx + house - 2) % 12 + 1;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$signNumber',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = signOffsets[house]!;
      textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
    }

    // 4. Group Planets by House
    final Map<int, List<String>> planetsInHouse = {};
    for (int house = 1; house <= 12; house++) {
      planetsInHouse[house] = [];
    }

    // Include Ascendant tag as a planet-like label "Asc" in house 1
    planetsInHouse[1]!.add('Asc');

    for (var planet in report.planets) {
      // Map planet name to short abbreviation
      final shortName = _getPlanetAbbr(planet.name);
      planetsInHouse[planet.house]?.add(shortName);
    }

    // 5. Draw Planets
    for (int house = 1; house <= 12; house++) {
      final planets = planetsInHouse[house]!;
      if (planets.isEmpty) continue;

      final center = houseCenters[house]!;
      // Arrange planet labels beautifully
      final String label = planets.join(' ');

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 2,
              )
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SouthIndianChartPainter extends CustomPainter {
  final AstroReport report;

  SouthIndianChartPainter({required this.report});

  // South Indian Rashi placement is fixed:
  // Pisces (0,0), Aries (1,0), Taurus (2,0), Gemini (3,0)
  // Aquarius (0,1), [Empty], [Empty], Cancer (3,1)
  // Capricorn (0,2), [Empty], [Empty], Leo (3,2)
  // Sagittarius (0,3), Scorpio (1,3), Libra (2,3), Virgo (3,3)
  static const Map<int, Point<int>> signCoords = {
    11: Point(0, 0), // Pisces
    0: Point(1, 0),  // Aries
    1: Point(2, 0),  // Taurus
    2: Point(3, 0),  // Gemini
    3: Point(3, 1),  // Cancer
    4: Point(3, 2),  // Leo
    5: Point(3, 3),  // Virgo
    6: Point(2, 3),  // Libra
    7: Point(1, 3),  // Scorpio
    8: Point(0, 3),  // Sagittarius
    9: Point(0, 2),  // Capricorn
    10: Point(0, 1), // Aquarius
  };

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double stepX = w / 4;
    final double stepY = h / 4;

    final linePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFA500).withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // 1. Draw outer boundary and grid lines
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Horizontal lines
    for (int i = 1; i <= 3; i++) {
      path.moveTo(0, stepY * i);
      path.lineTo(w, stepY * i);
    }
    // Vertical lines
    for (int i = 1; i <= 3; i++) {
      path.moveTo(stepX * i, 0);
      path.lineTo(stepX * i, h);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // Fill the center 2x2 blank cells with a dark shield
    final fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(stepX, stepY, stepX * 2, stepY * 2), fillPaint);

    // Draw central brand/watermark inside the chart
    final brandPainter = TextPainter(
      text: const TextSpan(
        text: 'ASTRO AI',
        style: TextStyle(
          color: Colors.amber,
          fontSize: 12,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    brandPainter.paint(
      canvas,
      Offset((w - brandPainter.width) / 2, (h - brandPainter.height) / 2),
    );

    // 2. Map Planet positions & Ascendant to Zodiac Sign boxes
    final Map<int, List<String>> planetsInSign = {};
    for (int sign = 0; sign < 12; sign++) {
      planetsInSign[sign] = [];
    }

    // Add Ascendant (Lagna)
    final lagnaSignIdx = AstrologyEngine.zodiacSigns.indexOf(report.ascendant);
    planetsInSign[lagnaSignIdx]!.add('Lagna');

    for (var planet in report.planets) {
      final signIdx = AstrologyEngine.zodiacSigns.indexOf(planet.sign);
      planetsInSign[signIdx]!.add(_getPlanetAbbr(planet.name));
    }

    // 3. Draw Sign names and Planets in each outer grid square
    for (int sign = 0; sign < 12; sign++) {
      final coord = signCoords[sign]!;
      final double cellX = coord.x * stepX;
      final double cellY = coord.y * stepY;

      // Draw Sign Name (small, top-left of the cell)
      final signName = AstrologyEngine.zodiacSigns[sign].substring(0, 3).toUpperCase();
      final signPainter = TextPainter(
        text: TextSpan(
          text: signName,
          style: TextStyle(
            color: const Color(0xFFFFD700).withOpacity(0.6),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      signPainter.paint(canvas, Offset(cellX + 4, cellY + 4));

      // Draw planet abbreviations (centered in cell)
      final planets = planetsInSign[sign]!;
      if (planets.isNotEmpty) {
        // Arrange planets in vertical stack or join
        final label = planets.join(' ');
        final planetPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        planetPainter.paint(
          canvas,
          Offset(
            cellX + (stepX - planetPainter.width) / 2,
            cellY + (stepY - planetPainter.height) / 2 + 5,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

String _getPlanetAbbr(String name) {
  switch (name) {
    case 'Sun':
      return 'Su';
    case 'Moon':
      return 'Mo';
    case 'Mars':
      return 'Ma';
    case 'Mercury':
      return 'Me';
    case 'Jupiter':
      return 'Ju';
    case 'Venus':
      return 'Ve';
    case 'Saturn':
      return 'Sa';
    case 'Rahu':
      return 'Ra';
    case 'Ketu':
      return 'Ke';
    default:
      return name.substring(0, 2);
  }
}
