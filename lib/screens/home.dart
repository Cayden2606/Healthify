import 'package:flutter/material.dart';

import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: Scaffold(
            body: Center(
              child: Text(
                'this is the home screen',
              ),
            ),
            bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 0)));
  }
}
