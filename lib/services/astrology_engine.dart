import 'dart:math';

import '../models/birth_details.dart';

class AstrologyEngine {
  static const List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static AstroReport generateReport(BirthDetails details) {
    // 1. Calculate days since Epoch (Jan 1, 2000)
    final birthDateTime = DateTime(
      details.dob.year,
      details.dob.month,
      details.dob.day,
      details.tob.hour,
      details.tob.minute,
    );
    final epoch = DateTime(2000, 1, 1, 0, 0, 0);
    final diffDays = birthDateTime.difference(epoch).inHours / 24.0;

    // 2. Calculate Sun's longitude
    // Sun moves ~360 degrees per 365.25 days (approx 0.9856 degrees/day)
    // On Jan 1, 2000, Sun was at approx 280.0 degrees (sidereal Lahiri coordinates)
    double sunLong = (280.0 + diffDays * 0.9856) % 360;
    if (sunLong < 0) sunLong += 360;
    final sunSignIndex = (sunLong / 30).floor();
    final sunSign = zodiacSigns[sunSignIndex];

    // 3. Calculate Moon's longitude
    // Moon moves ~13.17639 degrees/day
    // On Jan 1, 2000, Moon was at approx 195.4 degrees
    double moonLong = (195.4 + diffDays * 13.17639) % 360;
    if (moonLong < 0) moonLong += 360;
    final moonSignIndex = (moonLong / 30).floor();
    final moonSign = zodiacSigns[moonSignIndex];

    // 4. Calculate Nakshatra
    // There are 27 Nakshatras, each of 13.3333 degrees (13°20')
    final nakshatraIndex = (moonLong / 13.3333).floor() % 27;
    final nakshatraName = nakshatras[nakshatraIndex];
    final nakshatraLord = nakshatraLords[nakshatraIndex];

    // 5. Calculate Lagna (Ascendant)
    // Lagna shifts ~360 degrees in 24 hours (15 degrees per hour).
    // Lagna aligns with Sun sign at local sunrise (approx 6:00 AM).
    final double birthHourLocal = details.tob.hour + (details.tob.minute / 60.0);
    final double hourDiffFromSunrise = birthHourLocal - 6.0;
    double lagnaLong = (sunLong + hourDiffFromSunrise * 15.0) % 360;
    if (lagnaLong < 0) lagnaLong += 360;
    final lagnaSignIndex = (lagnaLong / 30).floor();
    final ascendantSign = zodiacSigns[lagnaSignIndex];
    final ascendantDegree = lagnaLong % 30;

    // Helper to calculate houses relative to Lagna
    int getHouse(double longi) {
      final signIdx = (longi / 30).floor();
      // In Vedic equal house system (Bhava), Lagna sign is the 1st House.
      int house = (signIdx - lagnaSignIndex + 1);
      if (house <= 0) house += 12;
      return house;
    }

    // 6. Calculate other planets (approximate positions)
    // Mars orbital period: 687 days (moves ~0.524 deg/day, epoch long: 330.0)
    double marsLong = (330.0 + diffDays * 0.524) % 360;
    if (marsLong < 0) marsLong += 360;

    // Jupiter orbital period: 11.86 years (moves ~0.083 deg/day, epoch long: 38.0)
    double jupiterLong = (38.0 + diffDays * 0.083) % 360;
    if (jupiterLong < 0) jupiterLong += 360;

    // Saturn orbital period: 29.45 years (moves ~0.033 deg/day, epoch long: 42.0)
    double saturnLong = (42.0 + diffDays * 0.033) % 360;
    if (saturnLong < 0) saturnLong += 360;

    // Venus orbital period: 224.7 days (moves ~1.602 deg/day, epoch long: 240.0)
    double venusLong = (240.0 + diffDays * 1.602) % 360;
    if (venusLong < 0) venusLong += 360;

    // Mercury orbital period: 88 days. Stays close to Sun, oscilates +/- 28 degrees.
    // Let's model it with a sine wave offset from the Sun
    double mercuryLong = (sunLong + 20 * sin(diffDays * 2 * pi / 88.0)) % 360;
    if (mercuryLong < 0) mercuryLong += 360;

    // Rahu & Ketu (Lunar Nodes) move backwards ~0.053 deg/day. Rahu epoch: 125.0
    double rahuLong = (125.0 - diffDays * 0.053) % 360;
    if (rahuLong < 0) rahuLong += 360;
    double ketuLong = (rahuLong + 180) % 360;

    final planets = [
      PlanetPosition(name: 'Sun', sign: zodiacSigns[(sunLong / 30).floor()], degree: sunLong % 30, house: getHouse(sunLong), nakshatra: nakshatras[(sunLong / 13.3333).floor() % 27], longitude: sunLong),
      PlanetPosition(name: 'Moon', sign: zodiacSigns[(moonLong / 30).floor()], degree: moonLong % 30, house: getHouse(moonLong), nakshatra: nakshatraName, longitude: moonLong),
      PlanetPosition(name: 'Mars', sign: zodiacSigns[(marsLong / 30).floor()], degree: marsLong % 30, house: getHouse(marsLong), nakshatra: nakshatras[(marsLong / 13.3333).floor() % 27], longitude: marsLong),
      PlanetPosition(name: 'Mercury', sign: zodiacSigns[(mercuryLong / 30).floor()], degree: mercuryLong % 30, house: getHouse(mercuryLong), nakshatra: nakshatras[(mercuryLong / 13.3333).floor() % 27], longitude: mercuryLong),
      PlanetPosition(name: 'Jupiter', sign: zodiacSigns[(jupiterLong / 30).floor()], degree: jupiterLong % 30, house: getHouse(jupiterLong), nakshatra: nakshatras[(jupiterLong / 13.3333).floor() % 27], longitude: jupiterLong),
      PlanetPosition(name: 'Venus', sign: zodiacSigns[(venusLong / 30).floor()], degree: venusLong % 30, house: getHouse(venusLong), nakshatra: nakshatras[(venusLong / 13.3333).floor() % 27], longitude: venusLong),
      PlanetPosition(name: 'Saturn', sign: zodiacSigns[(saturnLong / 30).floor()], degree: saturnLong % 30, house: getHouse(saturnLong), nakshatra: nakshatras[(saturnLong / 13.3333).floor() % 27], longitude: saturnLong),
      PlanetPosition(name: 'Rahu', sign: zodiacSigns[(rahuLong / 30).floor()], degree: rahuLong % 30, house: getHouse(rahuLong), nakshatra: nakshatras[(rahuLong / 13.3333).floor() % 27], longitude: rahuLong),
      PlanetPosition(name: 'Ketu', sign: zodiacSigns[(ketuLong / 30).floor()], degree: ketuLong % 30, house: getHouse(ketuLong), nakshatra: nakshatras[(ketuLong / 13.3333).floor() % 27], longitude: ketuLong),
    ];

    // Seeded random number generator for realistic astrological variety
    final int seed = details.dob.year + details.dob.month + details.dob.day + details.tob.hour + details.tob.minute;
    final random = Random(seed);

    // Generate reading contents
    final Map<String, dynamic> textReports = {
      'personality': _generatePersonalityReport(details, ascendantSign, moonSign, sunSign, nakshatraName, random),
      'career': _generateCareerReport(details, ascendantSign, moonSign, planets, random),
      'forecast_2026': _generateForecastReport(details, planets, random),
      'love_marriage': _generateLoveReport(details, planets, ascendantSign, random),
    };

    return AstroReport(
      details: details,
      ascendant: ascendantSign,
      ascendantDegree: ascendantDegree,
      moonSign: moonSign,
      sunSign: sunSign,
      nakshatra: nakshatraName,
      nakshatraLord: nakshatraLord,
      planets: planets,
      textReports: textReports,
    );
  }

  // ELEMENT STRENGTH CALCULATOR
  static Map<String, double> getElementStrengths(List<PlanetPosition> planets) {
    double fire = 0;
    double earth = 0;
    double air = 0;
    double water = 0;

    for (var planet in planets) {
      final sign = planet.sign;
      if (['Aries', 'Leo', 'Sagittarius'].contains(sign)) {
        fire += 1.0;
      } else if (['Taurus', 'Virgo', 'Capricorn'].contains(sign)) {
        earth += 1.0;
      } else if (['Gemini', 'Libra', 'Aquarius'].contains(sign)) {
        air += 1.0;
      } else if (['Cancer', 'Scorpio', 'Pisces'].contains(sign)) {
        water += 1.0;
      }
    }
    // Normalize to percentage
    double total = fire + earth + air + water;
    if (total == 0) return {'Fire': 25, 'Earth': 25, 'Air': 25, 'Water': 25};
    return {
      'Fire': (fire / total) * 100,
      'Earth': (earth / total) * 100,
      'Air': (air / total) * 100,
      'Water': (water / total) * 100,
    };
  }

  static String _generatePersonalityReport(
      BirthDetails details, String lagna, String moon, String sun, String nakshatra, Random rand) {
    final name = details.name;
    final subjectPronoun = details.gender.toLowerCase() == 'male' ? 'He' : 'She';
    final subjectPronounLower = details.gender.toLowerCase() == 'male' ? 'he' : 'she';
    final objectPronoun = details.gender.toLowerCase() == 'male' ? 'himself' : 'herself';
    final possessivePronoun = details.gender.toLowerCase() == 'male' ? 'his' : 'her';

    return '''
### 🌟 Personality & Nature

#### Core Personality
$name appears to have a combination of:
• Analytical thinking
• Independent mindset
• Strong observation skills
• A desire to improve $objectPronoun continuously

$subjectPronoun may not be someone who reveals everything immediately. Outside $subjectPronounLower is calm or reserved, but internally $subjectPronounLower thinks a lot.

---

#### Positive Traits
• **Intelligent and practical**: Good at understanding patterns and solving problems. Prefers logic over blind following.
• **Self-respecting personality**: Doesn't like unnecessary control from others. Wants freedom in decisions.
• **Learning ability**: Can pick up technical skills, languages, or complex subjects quickly.
• **Responsible nature**: Once $subjectPronounLower commits to something, $subjectPronounLower tries to complete it.
• **Leadership potential**: May naturally take charge in group situations.

---

#### ⚡ Weaknesses & Challenges
1. **Overthinking**: $subjectPronoun may analyze situations too deeply, worry about future outcomes, and delay decisions because $subjectPronounLower wants the "perfect" choice.
2. **High expectations**: $subjectPronoun may expect too much from $objectPronoun and expect similar dedication from others. This can create disappointment.
3. **Emotional expression**: $subjectPronoun may feel deeply but doesn't always communicate feelings openly, appearing detached.
4. **Stubbornness**: Once $subjectPronounLower believes something, changing $possessivePronoun opinion can be difficult. Arguments may happen because of strong opinions.

---

#### 🔥 Major Life Theme
"A person who builds success through knowledge, discipline, and self-improvement rather than shortcuts."

**Biggest growth comes from:**
• Controlling overthinking
• Taking calculated risks
• Improving communication
• Staying consistent
''';
  }

  static String _generateCareerReport(
      BirthDetails details, String lagna, String moon, List<PlanetPosition> planets, Random rand) {
    final name = details.name;
    final subjectPronoun = details.gender.toLowerCase() == 'male' ? 'He' : 'She';
    final subjectPronounLower = details.gender.toLowerCase() == 'male' ? 'he' : 'she';

    return '''
### 💼 Career & Professional Life

The chart indicates a person who may do well in fields involving:

#### 💻 Technology & Innovation
• Software engineering
• AI/ML
• Data science
• Cybersecurity
• Research
• Engineering

#### 📊 Management & Business
• Entrepreneurship
• Product management
• Consulting
• Leadership roles

#### 🎨 Creative + Analytical Fields
• Design + technology
• Content creation
• Digital businesses

---

#### 🚀 Career Strengths
$name is likely to succeed when:
• $subjectPronounLower gets independence
• $subjectPronounLower can experiment
• $subjectPronounLower keeps learning continuously

$subjectPronoun may struggle in jobs where:
• Every decision is controlled by someone else
• Work becomes repetitive

---

#### 💰 Money & Financial Outlook
• **Financial Pattern**: Money improves gradually rather than suddenly. Better financial stability comes after skill development.
• **Good Habits**: Saving early, avoiding unnecessary luxury spending, and investing in knowledge.
• **Spending Tendency**: Spending money on technology, hobbies, or interests.
''';
  }

  static String _generateForecastReport(BirthDetails details, List<PlanetPosition> planets, Random rand) {
    return '''
### 📈 2026 Career Outlook
(Traditional astrology interpretation)

2026 looks like a growth and transition year for ${details.name}.

#### 🌟 Opportunities in 2026
• Learning new skills
• Career direction becoming clearer
• Networking with useful people
• Chances to take bigger responsibilities

**Good year for:**
• Certifications
• Higher studies
• Competitive exams
• Building a professional identity

---

#### ⚠️ Challenges in 2026
• Confusion between multiple options
• Need for patience
• Avoid impulsive career decisions

---

#### 📝 Note
The second half of 2026 may feel more productive and rewarding than the beginning.
''';
  }

  static String _generateLoveReport(
      BirthDetails details, List<PlanetPosition> planets, String lagna, Random rand) {
    final name = details.name;
    final subjectPronoun = details.gender.toLowerCase() == 'male' ? 'He' : 'She';
    final subjectPronounLower = details.gender.toLowerCase() == 'male' ? 'he' : 'she';
    final possessivePronoun = details.gender.toLowerCase() == 'male' ? 'his' : 'her';
    final objectPronoun = details.gender.toLowerCase() == 'male' ? 'him' : 'her';
    final spousePossessive = details.gender.toLowerCase() == 'male' ? 'She' : 'He';

    return '''
### ❤️ Love Life & Marriage

#### 💌 Relationship Style
$name may be:
• Loyal once committed
• Protective toward partner
• Serious about relationships

But:
• Takes time to trust someone
• Doesn't like fake emotions
• Prefers a meaningful relationship over casual dating.

---

#### ⚠️ Possible Relationship Challenges
• **Emotional communication**: Partner may sometimes feel: *"$subjectPronounLower cares, but $subjectPronounLower doesn't express it enough."* $name will need to learn expressing appreciation and sharing feelings openly.
• **Independence vs attachment**: $subjectPronoun may need a partner who understands $possessivePronoun need for personal space.

---

#### 💍 Future Spouse Characteristics
Traditional interpretation suggests the spouse may be:
• **Personality**: Intelligent, mature, practical, and emotionally balanced.
• **Nature**: Supportive rather than dominating, with good communication skills and a family-oriented outlook.
• **Spouse Influence**: $spousePossessive may help $objectPronoun become more emotionally expressive and more balanced in life.
• **Possible Fields**: Education, Healthcare, Management, Technology, or Creative professions.

---

#### 💒 Marriage Prospects
A stable marriage is indicated more when $subjectPronounLower becomes personally and financially settled.
• **Favourable Period**: Mid to late 20s is more supportive than very early marriage.
• **Approximate Window**: **2029–2033** may be a stronger period for serious commitment.
''';
  }
}
