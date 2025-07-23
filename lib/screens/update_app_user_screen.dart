import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import '../utilities/firebase_calls.dart';

import 'package:phone_input/phone_input_package.dart';

class UpdateAppUserScreen extends StatefulWidget {
  const UpdateAppUserScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAppUserScreen> createState() => _UpdateAppUserScreenState();
}

class _UpdateAppUserScreenState extends State<UpdateAppUserScreen> {
  //TODO add contact, age, gender throughout this screen
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  // TextEditingController contactController = TextEditingController();
  PhoneController phoneController = PhoneController(PhoneNumber.parse('+65'));
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 2),
      appBar: AppBar(
        title: const Text(
          'Update Profile',
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        //     child: ElevatedButton(onPressed: () {}, child: Text("Save")),
        //   ),
        // ],
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
                  firstNameController.text = doc.get('name') ?? '';
                  lastNameController.text = doc.get('nameLast') ?? '';
                  // contactController.text = doc.get('contact') ?? '';
                  ageController.text = doc.get('age') ?? '';
                  genderController.text = doc.get('gender') ?? '';

                  // Handle phone number loading
                  String? storedPhone = doc.get('contact');
                  if (storedPhone != null && storedPhone.isNotEmpty) {
                    phoneController.value = PhoneNumber.parse(storedPhone);
                  }
                }
              }
              return Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541",
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  TextButton(
                    onPressed:
                        () {}, // TODO: Add a way for user to upload their own images
                    child: Text(
                      "Add picture",
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36, 0, 36, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          child: TextField(
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[850]),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                            ),
                            controller: firstNameController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                          child: TextField(
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[850]),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                            ),
                            controller: lastNameController,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                          child: PhoneInput(
                            style: theme.textTheme.headlineSmall,
                            countryCodeStyle: theme.textTheme.headlineSmall,
                            controller: phoneController,
                            defaultCountry: IsoCode.SG,
                            flagShape: BoxShape.rectangle,
                            showArrow: true,
                            flagSize: 20,
                            decoration: InputDecoration(
                              labelText: 'Phone (Mobile)',
                              labelStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[850]),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                            ),
                            validator: PhoneValidator.compose([
                              PhoneValidator.required(),
                              PhoneValidator.valid(),
                            ]),
                            countrySelectorNavigator:
                                CountrySelectorNavigator.searchDelegate(
                                    countryNameStyle:
                                        theme.textTheme.headlineSmall,
                                    countryCodeStyle:
                                        theme.textTheme.headlineSmall),
                            scrollPhysics: BouncingScrollPhysics(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: TextField(
                                    style: theme.textTheme.headlineSmall,
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Age',
                                      labelStyle: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.grey[850]),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                    ),
                                    controller: ageController,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      labelStyle: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.grey[850]),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                    ),
                                    value: genderController.text.isEmpty
                                        ? null
                                        : genderController.text,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Male', child: Text('Male')),
                                      DropdownMenuItem(
                                          value: 'Female',
                                          child: Text('Female')),
                                      DropdownMenuItem(
                                          value: 'Other', child: Text('Other')),
                                      DropdownMenuItem(
                                          value: 'Prefer not to say',
                                          child: Text(
                                            'Prefer not to say',
                                          )),
                                    ],
                                    onChanged: (String? value) {
                                      genderController.text = value ?? '';
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(45),
                          ),
                          onPressed: () async {
                            String phoneNumber =
                                phoneController.value?.international ?? '';
                            appUser = AppUser(
                              name: firstNameController.text,
                              nameLast: lastNameController.text,
                              email: auth.currentUser?.email ?? "",
                              userid: auth.currentUser?.uid ?? "",
                              // contact: contactController.text,
                              contact: phoneNumber,
                              age: ageController.text,
                              gender: genderController.text,
                            );
                            await FirebaseCalls().updateAppUser(appUser);
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text('Save'),
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
