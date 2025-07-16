import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import '../utilities/firebase_calls.dart';

class UpdateAppUserScreen extends StatefulWidget {
  const UpdateAppUserScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAppUserScreen> createState() => _UpdateAppUserScreenState();
}

class _UpdateAppUserScreenState extends State<UpdateAppUserScreen> {
  //TODO add contact, age, gender throughout this screen
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 2),
      appBar: AppBar(
        title: const Text(
          'Update Profile',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: ElevatedButton(onPressed: () {}, child: Text("Save")),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: appUsersCollection
                .where('userid', isEqualTo: auth.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  QueryDocumentSnapshot doc = snapshot.data!.docs[0];
                  nameController.text = doc.get('name') ?? '';
                  contactController.text = doc.get('contact') ?? '';
                  ageController.text = doc.get('age') ?? '';
                  genderController.text = doc.get('gender') ?? '';
                }
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36, 0, 36, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: TextField(
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            controller: nameController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: TextField(
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: 'Contact',
                              border: OutlineInputBorder(),
                            ),
                            controller: contactController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: TextField(
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                            controller: ageController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: TextField(
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            controller: genderController,
                          ),
                        ),
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            appUser = AppUser(
                              name: nameController.text,
                              email: auth.currentUser?.email ?? "",
                              userid: auth.currentUser?.uid ?? "",
                              contact: contactController.text,
                              age: ageController.text,
                              gender: genderController.text,
                            );
                            await FirebaseCalls().updateAppUser(appUser);
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
