import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../tempscreens/home_screen.dart';
import '../tempscreens/update_app_user_screen.dart';
import '../utilities/firebase_calls.dart';
import '../models/app_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
              ],
            );
          } else {
            //check if User is found in appUsers collection
            return FutureBuilder<AppUser>(
              future: FirebaseCalls().getAppUser(snapshot.data!.uid),
              builder: (context, snapshot2) {
                if (snapshot2.hasData) {
                  if (newUser) {
                    return const UpdateAppUserScreen();
                  } else {
                    return const HomeScreen();
                  }
                } else if (snapshot2.hasError) {
                  return Text('${snapshot2.error}');
                }
                return const CircularProgressIndicator();
              },
            );
          }
        },
      ),
    );
  }
}
