import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/models/appointment.dart';

import 'package:healthify/models/app_user.dart';

late AppUser appUser;
bool newUser = false;

FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference appUsersCollection =
    FirebaseFirestore.instance.collection('appUsers');
CollectionReference appointmentsCollection =
    FirebaseFirestore.instance.collection('appointments');
CollectionReference clinicsCollection =
    FirebaseFirestore.instance.collection('clinics');

class FirebaseCalls {
  Future<AppUser> getAppUser(String uid) async {
    QuerySnapshot querySnap =
        await appUsersCollection.where('userid', isEqualTo: uid).get();

    if (querySnap.docs.isNotEmpty) {
      QueryDocumentSnapshot doc = querySnap.docs[0];
      appUser = AppUser(
        name: doc.get('name'),
        nameLast: doc.get('nameLast'),
        email: doc.get('email'),
        userid: doc.get('userid'),
        contact: doc.get('contact'),
        age: doc.get('age'),
        gender: doc.get('gender'),
        profilePic: doc.get('profilePic'),
        darkMode: doc.data().toString().contains('darkMode')
            ? doc.get('darkMode')
            : false,
        colorSeed: doc.data().toString().contains('colorSeed')
            ? Color(doc.get('colorSeed'))
            : const Color(0xFFBBDEFB),
      );
    } else {
      newUser = true;
      appUser = AppUser(
        name: auth.currentUser?.displayName ?? '',
        nameLast: auth.currentUser?.displayName ?? '',
        email: auth.currentUser?.email ?? '',
        userid: auth.currentUser?.uid ?? '',
        contact: '',
        age: '',
        gender: '',
        profilePic: '',
        darkMode: false,
        colorSeed: const Color(0xFFBBDEFB),
      );
    }
    return appUser;
  }

  Future<void> updateAppUser(AppUser appUser) async {
    //check if there is an existing record of user
    QuerySnapshot querySnap = await appUsersCollection
        .where('userid', isEqualTo: auth.currentUser?.uid)
        .get();

    if (querySnap.docs.isNotEmpty) {
      //Existing user
      QueryDocumentSnapshot doc = querySnap.docs[0];
      await doc.reference.update({
        'name': appUser.name,
        'nameLast': appUser.nameLast,
        'email': appUser.email,
        'age': appUser.age,
        'gender': appUser.gender,
        'contact': appUser.contact,
        'profilePic': appUser.profilePic,
        'darkMode': appUser.darkMode,
        'colorSeed': appUser.colorSeed.value,
      });
    } else {
      //New user
      await appUsersCollection.add({
        'name': appUser.name,
        'nameLast': appUser.nameLast,
        'email': appUser.email,
        'userid': appUser.userid,
        'age': appUser.age,
        'gender': appUser.gender,
        'contact': appUser.contact,
        'profilePic': appUser.profilePic,
        'darkMode': appUser.darkMode,
        'colorSeed': appUser.colorSeed.value,
      });
    }
  }

  Future<void> saveUserSavedClinics(Set<String> savedClinicPlaceIds) async {
    QuerySnapshot querySnap = await appUsersCollection
        .where('userid', isEqualTo: auth.currentUser?.uid)
        .get();

    if (querySnap.docs.isNotEmpty) {
      QueryDocumentSnapshot userDoc = querySnap.docs[0];
      await userDoc.reference.update({
        'savedClinics': savedClinicPlaceIds.toList(),
      });
    } else {
      throw Exception('User not found');
    }
  }

  Future<List<Clinic>> getUserSavedClinics() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Fetch the user document
    final userDocSnap = await appUsersCollection
        .where('userid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (userDocSnap.docs.isEmpty) {
      throw Exception('User not found');
    }

    final userDoc = userDocSnap.docs.first;
    final userData = userDoc.data() as Map<String, dynamic>?;

    // Get the list of saved clinic IDs from the user document
    if (userData == null ||
        !userData.containsKey('savedClinics') ||
        !(userData['savedClinics'] is List)) {
      return []; // No saved clinics or field is malformed
    }

    final List<String> savedClinicIds =
        List<String>.from(userData['savedClinics']);

    if (savedClinicIds.isEmpty) {
      return []; // The list of saved clinics is empty
    }

    // Fetch the clinic objects from the 'clinics' collection
    // using the retrieved IDs and dot notation for the nested field.
    final clinicsQuery = await clinicsCollection
        .where('properties.place_id', whereIn: savedClinicIds)
        .get();

    // Deserialize each clinic document into a Clinic object
    return clinicsQuery.docs
        .map((doc) => Clinic.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Checks if a clinic exists by its place_id and adds it to the collection if not found.
  Future<void> addClinicIfNotFound(Clinic clinic) async {
    try {
      final docRef = clinicsCollection.doc(clinic.placeId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Document does not exist, so create it.
        await docRef.set(clinic.toJson());
        print('Added new clinic to database: ${clinic.name}');
      }
    } catch (e) {
      print('Error adding clinic to database: $e');
    }
  }

  Future<void> addAppointment({
    required String placeId,
    required DateTime appointmentDateTime,
    required String serviceCategory,
    required String serviceType,
    String additionalInfo = '',
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await appointmentsCollection.add({
      'userId': user.uid,
      'placeId': placeId, // Store the entire clinic object
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      'serviceCategory': serviceCategory,
      'serviceType': serviceType,
      'status': 'upcoming', // Default status for a new appointment
      'additionalInfo': additionalInfo, // Optional field for additional info
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Appointment added successfully');
  }

  Future<void> updateAppointment({
    required String id, // Firestore document id to update
    String? placeId,
    DateTime? appointmentDateTime,
    String? serviceCategory,
    String? serviceType,
    String? additionalInfo,
    String? status, // e.g., 'upcoming' | 'passed' | 'cancelled'
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Build a partial update map so you can pass only fields you want to change
    final Map<String, dynamic> data = {
      if (placeId != null) 'placeId': placeId,
      if (appointmentDateTime != null)
        'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      if (serviceCategory != null) 'serviceCategory': serviceCategory,
      if (serviceType != null) 'serviceType': serviceType,
      if (additionalInfo != null) 'additionalInfo': additionalInfo,
      if (status != null) 'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (data.length == 1) {
      // only updatedAt would be written → nothing meaningful to update
      return;
    }

    await appointmentsCollection.doc(id).update(data);
  }

  Future<void> deleteAppointment(
    String id, {
    bool soft = false, // set true to just mark as cancelled
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final ref = appointmentsCollection.doc(id);
    final snap = await ref.get();

    if (!snap.exists) {
      throw Exception('Appointment not found');
    }

    final data = snap.data() as Map<String, dynamic>;
    if (data['userId'] != user.uid) {
      throw Exception('You are not allowed to delete this appointment');
    }

    if (soft) {
      await ref.update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  Future<List<Appointment>> getAppointments() async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Get user appointments
    final snap = await appointmentsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    if (snap.docs.isEmpty) return [];

    // Compare and update statuses in a single batch
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    int updates = 0;

    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // guard against malformed docs
      if (!data.containsKey('appointmentDateTime') ||
          !data.containsKey('status')) continue;

      final apptTime =
          (data['appointmentDateTime'] as Timestamp).toDate().toLocal();
      final status = (data['status'] as String);

      // Only flip 'upcoming' -> 'passed' when time has elapsed
      if (status == 'upcoming' && apptTime.isBefore(now)) {
        batch.update(doc.reference, {'status': 'passed'});
        updates++;
      }
    }

    if (updates > 0) {
      await batch.commit();
    }

    final clinicIds = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['placeId'] as String)
        .toSet()
        .toList();

    if (clinicIds.isEmpty) return [];

    final clinicsSnap = await clinicsCollection
        .where('properties.place_id', whereIn: clinicIds)
        .get();

    final clinicsMap = <String, Clinic>{
      for (var d in clinicsSnap.docs)
        if (d.data() != null)
          (d.data() as Map<String, dynamic>)['properties']['place_id']:
              Clinic.fromJson(d.data() as Map<String, dynamic>)
    };

    final List<Appointment> appointments = [];
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final clinicId = data['placeId'] as String;
      final clinic = clinicsMap[clinicId];
      if (clinic == null) continue;

      final apptTime =
          (data['appointmentDateTime'] as Timestamp).toDate().toLocal();
      final createdAtTs = data['createdAt'];
      final createdAt = createdAtTs is Timestamp
          ? createdAtTs.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);

      appointments.add(
        Appointment(
          id: doc.id,
          userId: data['userId'],
          clinic: clinic,
          appointmentDateTime: apptTime,
          serviceCategory: data['serviceCategory'],
          serviceType: data['serviceType'],
          status: data['status'],
          createdAt: createdAt,
          additionalInfo: data['additionalInfo'] ?? '',
        ),
      );
    }

    return appointments;
  }

  // Update only themes
  Future<void> updateThemePreferences(bool darkMode, Color colorSeed) async {
    QuerySnapshot querySnap = await appUsersCollection
        .where('userid', isEqualTo: auth.currentUser?.uid)
        .get();

    if (querySnap.docs.isNotEmpty) {
      QueryDocumentSnapshot doc = querySnap.docs[0];
      await doc.reference.update({
        'darkMode': darkMode,
        'colorSeed': colorSeed.value,
      });

      // Update local appUser instance
      appUser.darkMode = darkMode;
      appUser.colorSeed = colorSeed;
    }
  }

  // firebase call to search through clinics collection, and for every clinic that contains the user input, we return the matching clinics
  Future<List<Clinic>> searchClinics(String query) async {
    if (query.trim().isEmpty) return [];

    final snap = await clinicsCollection
        .where('properties.name', isGreaterThanOrEqualTo: query)
        .where('properties.name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snap.docs
        .map((doc) => Clinic.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // find nearest clinic
  Future<Clinic?> findNearestClinic(LatLng userLocation, double Function(double, double, double, double) _calculateDistance) async {
    final snap = await clinicsCollection.get();

    if (snap.docs.isEmpty) return null;

    // Find the clinic with the minimum distance
    Clinic? nearestClinic;
    double minDistance = double.infinity;

    for (final doc in snap.docs) {
      final clinic = Clinic.fromJson(doc.data() as Map<String, dynamic>);
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        clinic.lat,
        clinic.lon,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestClinic = clinic;
      }
    }

    return nearestClinic;
  }

}
