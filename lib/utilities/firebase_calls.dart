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
        email: doc.get('email'),
        userid: doc.get('userid'),
        //TODO add contact, age, gender
      );
    } else {
      newUser = true;
      appUser = AppUser(
        name: auth.currentUser?.displayName ?? '',
        email: auth.currentUser?.email ?? '',
        userid: auth.currentUser?.uid ?? '',
        //TODO add contact, age, gender
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
        //TODO add contact, age, gender
      });
    } else {
      //New user
      await appUsersCollection.add({
        'name': appUser.name,
        'email': appUser.email,
        'userid': appUser.userid
        //TODO add contact, age, gender
      });
    }
  }
  //TODO addAppointment() and getAppointments
}
