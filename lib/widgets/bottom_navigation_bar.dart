import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 65,
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          label: 'Clinics',
          icon: Icon(Icons.local_hospital),
        ),
        NavigationDestination(
          label: 'AI',
          icon: Icon(Icons.auto_awesome),
        ),
      ],
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/clinics');
            break;;
          case 2:
            Navigator.pushReplacementNamed(context, '/assistant');
            break;
        }
      },
    );
  }
}
