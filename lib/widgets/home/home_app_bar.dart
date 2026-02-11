import 'package:flutter/material.dart';
import 'package:healthify/utilities/firebase_calls.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: theme.colorScheme.onPrimaryFixedVariant,
          backgroundImage: appUser.profilePic.isNotEmpty
              ? NetworkImage(appUser.profilePic)
              : null,
          child: appUser.profilePic.isEmpty
              ? Text(
                  '${appUser.name.isNotEmpty ? appUser.name[0] : ''}${appUser.nameLast.isNotEmpty ? appUser.nameLast[0] : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        )
      ],
    );
  }
}