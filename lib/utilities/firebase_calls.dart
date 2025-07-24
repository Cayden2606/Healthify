import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

late AppUser appUser;
bool newUser = false;

FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference appUsersCollection =
    FirebaseFirestore.instance.collection('appUsers');
CollectionReference appointmentsCollection =
    FirebaseFirestore.instance.collection('appointments');

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
          profilePic: doc.get('profilePic'));
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
          profilePic: '');
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
      });
    }
  }
  //TODO addAppointment() and getAppointments
}
