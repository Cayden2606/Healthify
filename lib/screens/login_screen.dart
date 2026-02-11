import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../utilities/status_bar_utils.dart';
import 'home.dart';
import 'update_app_user_screen.dart';
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
    // Change status bar color
    StatusBarUtils.setStatusBar(context);

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
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
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot2.hasError) {
                  return Center(child: Text('Error: ${snapshot2.error}'));
                } else if (snapshot2.hasData) {
                  if (newUser) {
                    return const UpdateAppUserScreen();
                  } else {
                    return const HomeScreen();
                  }
                } else if (snapshot2.hasError) {
                  return Text('${snapshot2.error}');
                }
                return Center(child: const CircularProgressIndicator());
              },
            );
          }
        },
      ),
    );
  }
}
