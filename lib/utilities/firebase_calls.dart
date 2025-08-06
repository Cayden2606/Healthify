import 'dart:ui';

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
      'serviceType': serviceType,
      'status': 'upcoming', // Default status for a new appointment
      'additionalInfo': additionalInfo, // Optional field for additional info
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Appointment added successfully');
  }

  Future<List<Appointment>> getAppointments() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final appointmentsSnap = await appointmentsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    if (appointmentsSnap.docs.isEmpty) {
      return [];
    }

    final clinicIds = appointmentsSnap.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['placeId'] as String)
        .toSet()
        .toList();

    if (clinicIds.isEmpty) {
      return []; // Should not happen if appointments exist
    }

    final clinicsSnap = await clinicsCollection
        .where('properties.place_id', whereIn: clinicIds)
        .get();

    final clinicsMap = <String, Clinic>{
      for (var doc in clinicsSnap.docs)
        if (doc.data() != null)
          (doc.data() as Map<String, dynamic>)['properties']['place_id']:
              Clinic.fromJson(doc.data() as Map<String, dynamic>)
    };

    final List<Appointment> appointments = [];
    for (final doc in appointmentsSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final clinicId = data['placeId'] as String;
      final clinic = clinicsMap[clinicId];

      if (clinic != null) {
        final appointmentDateTime =
            (data['appointmentDateTime'] as Timestamp).toDate();
        final createdAt = (data['createdAt'] as Timestamp).toDate();

        appointments.add(
          Appointment(
            id: doc.id,
            userId: data['userId'],
            clinic: clinic,
            appointmentDateTime: appointmentDateTime,
            serviceType: data['serviceType'],
            status: data['status'],
            createdAt: createdAt,
            additionalInfo: data['additionalInfo'] ?? '', // Handle optional field
          )
        );
      }
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
}
