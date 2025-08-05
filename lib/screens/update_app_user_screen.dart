import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../utilities/firebase_calls.dart';

import 'package:phone_input/phone_input_package.dart';

import '../utilities/status_bar_utils.dart';

class UpdateAppUserScreen extends StatefulWidget {
  const UpdateAppUserScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAppUserScreen> createState() => _UpdateAppUserScreenState();
}

class _UpdateAppUserScreenState extends State<UpdateAppUserScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  // TextEditingController contactController = TextEditingController();
  PhoneController phoneController = PhoneController(PhoneNumber.parse('+65'));
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  // Cloudinary stuff
  final String cloudName = 'dv7xjn1wg';
  final String uploadPreset = 'healthify_pfp';
  File? tempImage;
  bool removePic = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<String?> uploadToCloudinary(File imageFile) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        tempImage = File(picked.path);
      });
    }
  }

  void _removeProfilePic() {
    setState(() {
      tempImage = null;
      removePic = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    StatusBarUtils.setStatusBar(context);

    ThemeData theme = Theme.of(context);

    return Scaffold(
      // bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 2),
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

              // Choose the avatar to display
              CircleAvatar displayAvatar;

              if (tempImage != null) {
                displayAvatar = CircleAvatar(
                  radius: 54,
                  backgroundImage: FileImage(tempImage!),
                  backgroundColor: Colors.transparent,
                );
              } else if (appUser.profilePic.isNotEmpty && !removePic) {
                displayAvatar = CircleAvatar(
                  radius: 54,
                  backgroundImage: NetworkImage(appUser.profilePic),
                  backgroundColor: Colors.transparent,
                );
              } else {
                final initials =
                    '${firstNameController.text.isNotEmpty ? firstNameController.text[0] : ''}${lastNameController.text.isNotEmpty ? lastNameController.text[0] : ''}';
                displayAvatar = CircleAvatar(
                  radius: 54,
                  backgroundColor: theme.colorScheme.onPrimaryFixedVariant,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      displayAvatar,
                      if (tempImage != null || appUser.profilePic.isNotEmpty)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _removeProfilePic,
                            child: const CircleAvatar(
                              radius: 13,
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.delete_forever,
                                  size: 15, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    // TODO: Add a way for user to upload their own images
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                            child: TextFormField(
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                labelText: 'First Name *',
                                labelStyle: theme.textTheme.bodyMedium,
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                              ),
                              controller: firstNameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'First name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                            child: TextFormField(
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                labelText: 'Last Name (Optional)',
                                labelStyle: theme.textTheme.bodyMedium,
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
                                labelText: 'Phone (Mobile) *',
                                labelStyle: theme.textTheme.bodyMedium,
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
                                    child: TextFormField(
                                      style: theme.textTheme.headlineSmall,
                                      textAlign: TextAlign.left,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Age *',
                                        labelStyle: theme.textTheme.bodyMedium,
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16))),
                                      ),
                                      controller: ageController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Age is required';
                                        }
                                        final age = int.tryParse(value);
                                        if (age == null ||
                                            age < 1 ||
                                            age > 120) {
                                          return 'Please enter a valid age (1-120)';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Gender (Optional)',
                                        labelStyle: theme.textTheme.bodyMedium,
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
                                            value: 'Other',
                                            child: Text('Other')),
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
                                backgroundColor:
                                    theme.colorScheme.primaryContainer),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              FocusScope.of(context).unfocus();
                              String phoneNumber =
                                  phoneController.value?.international ?? '';

                              // Upload image if selected
                              String? uploadedUrl;
                              if (tempImage != null) {
                                uploadedUrl =
                                    await uploadToCloudinary(tempImage!);
                              }

                              // Create and save the updated user
                              appUser = AppUser(
                                name: firstNameController.text,
                                nameLast: lastNameController.text,
                                email: auth.currentUser?.email ?? "",
                                userid: auth.currentUser?.uid ?? "",
                                contact: phoneNumber,
                                age: ageController.text.toString(),
                                gender: genderController.text,
                                profilePic: removePic
                                    ? ''
                                    : (uploadedUrl ?? appUser.profilePic),
                                darkMode: appUser.darkMode,
                                colorSeed: appUser.colorSeed,
                              );

                              await FirebaseCalls().updateAppUser(appUser);
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
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
