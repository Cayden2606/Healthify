import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import 'package:healthify/utilities/firebase_calls.dart';

class HealthAssistant extends StatefulWidget {
  const HealthAssistant({super.key});

  @override
  State<HealthAssistant> createState() => _HealthAssistantState();
}

class _HealthAssistantState extends State<HealthAssistant> {

  ChatUser currentUser = ChatUser(id: "0", firstName: appUser.name);
  ChatUser
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gemini',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 2),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {return DashChat(currentUser: currentUser, onSend: onSend, messages: messages)}
}
