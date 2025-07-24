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
        // NavigationDestination(
        //   label: 'User',
        //   icon: Icon(Icons.person),
        // ),
        NavigationDestination(
          label: 'AI',
          icon: Icon(Icons.auto_awesome),
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/clinics');
            break;
          // case 2:
          //   Navigator.pushReplacementNamed(context, '/user');
          //   break;
          case 2:
            Navigator.pushReplacementNamed(context, '/assistant');
            break;
          case 3:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
