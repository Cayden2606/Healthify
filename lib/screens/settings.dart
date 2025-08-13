import 'package:flutter/material.dart';

import 'package:healthify/models/settings_item.dart';
import 'package:healthify/models/theme_colors.dart';
import 'package:healthify/screens/update_app_user_screen.dart';

import 'package:healthify/utilities/firebase_calls.dart';

import '../utilities/status_bar_utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.darkMode,
    required this.toggleDarkMode,
    required this.userColor,
    required this.setUserColor,
    required this.onThemeInitialize,
  });

  final bool darkMode;
  final void Function(bool, {bool saveToFirebase}) toggleDarkMode;
  final Color userColor;
  final void Function(Color, {bool saveToFirebase}) setUserColor;
  final VoidCallback onThemeInitialize;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentLanguage = 'English';

  final initials =
      '${appUser.name.isNotEmpty ? appUser.name[0] : ''}${appUser.nameLast.isNotEmpty ? appUser.nameLast[0] : ''}';

  @override
  void initState() {
    super.initState();
    // Initialize theme when settings page loads
    widget.onThemeInitialize();
  }

  void _languageChange(String? value) {
    setState(() {
      _currentLanguage = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    List<SettingsItem> generalItems = [
      SettingsItem(
        icon: Icons.dark_mode,
        title: 'Dark Mode',
        subtitle: 'Enable dark mode',
        trailing: Switch(
          value: widget.darkMode,
          thumbIcon: widget.darkMode
              ? WidgetStateProperty.all(const Icon(Icons.check))
              : null,
          onChanged: widget.toggleDarkMode,
        ),
        onTap: () => {},
      ),
      SettingsItem(
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Enable notifications',
        trailing: Switch(value: false, onChanged: (bool value) => {}),
        onTap: () => {},
      ),
      SettingsItem(
        icon: Icons.language,
        title: 'Language',
        subtitle: 'Select language',
        trailing: DropdownButton(
          value: _currentLanguage,
          items: [
            DropdownMenuItem(
              value: 'English',
              child: Text('English'),
            ),
            DropdownMenuItem(
              value: '中文',
              child: Text('中文'),
            ),
            DropdownMenuItem(
              value: 'Bahasa Melayu',
              child: Text('Bahasa Melayu'),
            ),
            DropdownMenuItem(
              value: 'தமிழ்',
              child: Text('தமிழ்'),
            ),
          ],
          onChanged: _languageChange,
        ),
        onTap: () => {},
      ),
    ];

    List<SettingsItem> themingItems = [
      SettingsItem(
        icon: Icons.color_lens,
        title: 'Theme',
        subtitle: 'Customise theme colours',
        trailing: ElevatedButton(
          onPressed: () => {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: MediaQuery.sizeOf(context).height *
                      0.5, // adjust the height to your liking
                  padding: const EdgeInsets.all(16),
                  // https://api.flutter.dev/flutter/widgets/GridView-class.html
                  child: GridView.builder(
                    // https://api.flutter.dev/flutter/widgets/SliverGridDelegateWithFixedCrossAxisCount-class.html
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // number of columns
                    ),
                    itemCount: themeColors.length, // number of colors
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          widget.setUserColor(themeColors[index]);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeColors[index],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _theme.colorScheme.primaryFixed,
            shape: const CircleBorder(),
          ),
          child: const Icon(Icons.colorize_rounded),
        ),
        onTap: () => {},
      ),
    ];

    List<SettingsItem> privacyItems = [
      SettingsItem(
        icon: Icons.lock,
        title: 'Privacy Policy',
        subtitle: 'View privacy policy',
        onTap: () => {},
      ),
      SettingsItem(
        icon: Icons.security,
        title: 'Terms of Service',
        subtitle: 'View terms of service',
        onTap: () => {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        systemOverlayStyle: StatusBarUtils.getStatusBarStyle(context),
        actions: [
          IconButton(
            onPressed: () {
              // Make light mode and Blue
              auth.signOut();
              widget.toggleDarkMode(false, saveToFirebase: false);
              widget.setUserColor(Colors.blue[100]!, saveToFirebase: false);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child:
                      Text("Profile", style: _theme.textTheme.headlineMedium),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UpdateAppUserScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor:
                            _theme.colorScheme.onPrimaryFixedVariant,
                        backgroundImage: appUser.profilePic.isNotEmpty
                            ? NetworkImage(appUser.profilePic)
                            : null,
                        child: appUser.profilePic.isEmpty
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${appUser.name} ${appUser.nameLast}',
                              style: _theme.textTheme.headlineMedium!
                                  .copyWith(fontSize: 16),
                            ),
                            Text(
                              appUser.contact,
                              style: _theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ),
            BuildSettingsSection(
                header: 'General',
                items: generalItems,
                iconBackgroundColour: _theme.colorScheme.primaryFixed,
                iconColour: _theme.colorScheme.onPrimaryFixedVariant),
            BuildSettingsSection(
                header: 'Theming',
                items: themingItems,
                iconBackgroundColour: _theme.colorScheme.secondaryFixed,
                iconColour: _theme.colorScheme.onSecondaryFixedVariant),
            BuildSettingsSection(
                header: 'Privacy',
                items: privacyItems,
                iconBackgroundColour: _theme.colorScheme.tertiaryFixed,
                iconColour: _theme.colorScheme.onTertiaryFixedVariant),
            SizedBox(height: 40)
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 3),
    );
  }
}

class BuildSettingsSection extends StatelessWidget {
  const BuildSettingsSection(
      {super.key,
      required this.header,
      required this.items,
      required this.iconBackgroundColour,
      required this.iconColour});

  final String header;
  final List<SettingsItem> items;
  final Color? iconBackgroundColour;
  final Color? iconColour;

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(header, style: _theme.textTheme.headlineMedium),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          color: _theme.colorScheme.surfaceBright,
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 0.0),
                  leading: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: iconBackgroundColour),
                      child: Icon(items[index].icon, color: iconColour)),
                  title: Text(items[index].title,
                      style: _theme.textTheme.headlineMedium!
                          .copyWith(fontSize: 16)),
                  subtitle: Text(
                      items[index].subtitle != null
                          ? items[index].subtitle!
                          : '',
                      style: _theme.textTheme.bodySmall),
                  trailing: items[index].trailing,
                  onTap: items[index].onTap,
                );
              }),
        ),
      ],
    );
  }
}
