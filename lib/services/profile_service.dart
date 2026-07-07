import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/birth_details.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _chartsCollection {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('birth_charts');
  }

  Future<List<BirthDetails>> getProfiles() async {
    final col = _chartsCollection;
    if (col == null) return [];

    try {
      final snapshot = await col.get().timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Failed to retrieve profiles. Connection timed out.');
      });
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Set document id
        data['id'] = doc.id;
        return BirthDetails.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching profiles: $e");
      return [];
    }
  }

  Future<void> saveProfile(BirthDetails profile) async {
    final col = _chartsCollection;
    if (col == null) throw Exception('User not logged in');

    await col.doc(profile.id).set(profile.toJson()).timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Failed to save profile. Connection timed out.');
    });
  }

  Future<void> deleteProfile(String id) async {
    final col = _chartsCollection;
    if (col == null) throw Exception('User not logged in');

    await col.doc(id).delete().timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('Failed to delete profile. Connection timed out.');
    });
  }
}
