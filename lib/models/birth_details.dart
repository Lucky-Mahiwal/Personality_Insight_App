import 'package:flutter/material.dart';

class BirthDetails {
  final String id;
  final String name;
  final String gender;
  final DateTime dob;
  final TimeOfDay tob;
  final String place;
  final double latitude;
  final double longitude;
  final double timezone;

  BirthDetails({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.tob,
    required this.place,
    this.latitude = 28.6139, // Default to Delhi
    this.longitude = 77.2090,
    this.timezone = 5.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob.toIso8601String(),
      'tob_hour': tob.hour,
      'tob_minute': tob.minute,
      'place': place,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  factory BirthDetails.fromJson(Map<String, dynamic> json) {
    return BirthDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      dob: DateTime.parse(json['dob'] as String),
      tob: TimeOfDay(
        hour: json['tob_hour'] as int,
        minute: json['tob_minute'] as int,
      ),
      place: json['place'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: (json['timezone'] as num).toDouble(),
    );
  }
}

class PlanetPosition {
  final String name;
  final String sign;
  final double degree;
  final int house;
  final String nakshatra;
  final double longitude;

  PlanetPosition({
    required this.name,
    required this.sign,
    required this.degree,
    required this.house,
    required this.nakshatra,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sign': sign,
      'degree': degree,
      'house': house,
      'nakshatra': nakshatra,
      'longitude': longitude,
    };
  }

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      name: json['name'] as String,
      sign: json['sign'] as String,
      degree: (json['degree'] as num).toDouble(),
      house: json['house'] as int,
      nakshatra: json['nakshatra'] as String,
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class AstroReport {
  final BirthDetails details;
  final String ascendant; // Lagna
  final double ascendantDegree;
  final String moonSign; // Rashi
  final String sunSign;
  final String nakshatra;
  final String nakshatraLord;
  final List<PlanetPosition> planets;
  final Map<String, dynamic> textReports; // Keys: personality, career, 2026, love_marriage

  AstroReport({
    required this.details,
    required this.ascendant,
    required this.ascendantDegree,
    required this.moonSign,
    required this.sunSign,
    required this.nakshatra,
    required this.nakshatraLord,
    required this.planets,
    required this.textReports,
  });

  Map<String, dynamic> toJson() {
    return {
      'details': details.toJson(),
      'ascendant': ascendant,
      'ascendantDegree': ascendantDegree,
      'moonSign': moonSign,
      'sunSign': sunSign,
      'nakshatra': nakshatra,
      'nakshatraLord': nakshatraLord,
      'planets': planets.map((p) => p.toJson()).toList(),
      'textReports': textReports,
    };
  }

  factory AstroReport.fromJson(Map<String, dynamic> json) {
    return AstroReport(
      details: BirthDetails.fromJson(json['details'] as Map<String, dynamic>),
      ascendant: json['ascendant'] as String,
      ascendantDegree: (json['ascendantDegree'] as num).toDouble(),
      moonSign: json['moonSign'] as String,
      sunSign: json['sunSign'] as String,
      nakshatra: json['nakshatra'] as String,
      nakshatraLord: json['nakshatraLord'] as String,
      planets: (json['planets'] as List<dynamic>)
          .map((p) => PlanetPosition.fromJson(p as Map<String, dynamic>))
          .toList(),
      textReports: json['textReports'] as Map<String, dynamic>,
    );
  }
}
