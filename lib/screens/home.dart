import 'package:flutter/material.dart';

import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';

import 'package:healthify/utilities/firebase_calls.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  onPressed: () {
                    auth.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Center(
              child: Text('Welcome ${appUser.name}'),
            ),
            bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 0)));
  }
}
