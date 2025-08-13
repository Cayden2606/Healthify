import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/models/gemini_appointment.dart';
import 'package:healthify/screens/make_appointments_screen.dart';
import 'package:healthify/widgets/bottom_navigation_bar.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:healthify/utilities/status_bar_utils.dart';
import 'package:latlong2/latlong.dart';

final Map<String, List<String>> allowedCategories = {
  'Doctor Consultation': [
    'General Consultation',
    'Chronic Conditions Follow-up',
    'Family Planning Consultation',
    'Specialist Referral Review',
  ],
  'Vaccination': [
    'Adult Vaccination',
    'Child Vaccination (6 months - 17 years)',
    'COVID-19 Vaccination',
    'Flu Vaccination',
    'Travel Vaccination',
  ],
  'Screening & Tests': [
    'Cervical Cancer Screening',
    'Diabetic Eye Screening',
    'Mammogram Screening',
    'Blood Pressure Check',
    'Cholesterol Test',
  ],
  'Nursing Services': [
    'Wound Dressing',
    'Injection Administration',
    'Health Education',
    'Postnatal Care',
  ],
  'Allied Health': [
    'Nutritionist Consultation',
    'Physiotherapy',
    'Medical Social Service',
    'Financial Counselling',
  ],
  'Dental': [
    'Dental Cleaning',
    'Dental Check-up',
    'Fluoride Treatment',
    'Dental X-Ray',
  ],
};

class HealthAssistant extends StatefulWidget {
  final String? shortCutQuery;
  const HealthAssistant({this.shortCutQuery, super.key});

  @override
  State<HealthAssistant> createState() => _HealthAssistantState();
}

class _HealthAssistantState extends State<HealthAssistant> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  Timer? typingTimer;
  int dotCount = 0;

  ChatUser currentUser = ChatUser(id: "0", firstName: appUser.name);
  ChatUser geminiUser = ChatUser(
      id: '1',
      firstName: "Gemini",
      profileImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Google_Gemini_icon_2025.svg/1024px-Google_Gemini_icon_2025.svg.png');

  bool showBookButton = false;
  GeminiAppointment? geminiAppointment;

  bool userBookAppointmentIntent = false; // Add this to your state

  @override
  void initState() {
    super.initState();

    // If a shortcut query was provided, send it automatically (hidden from user)
    if (widget.shortCutQuery != null && widget.shortCutQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(
            ChatMessage(
              user: currentUser,
              createdAt: DateTime.now(),
              text: widget.shortCutQuery!,
            ),
            isShortcut: true); // Pass flag to indicate it's a shortcut
      });
    }

    messages.clear();
    geminiAppointment = null;
    userBookAppointmentIntent = false;
    showBookButton = false;
    initGreetings = true;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "morning";
    if (hour < 17) return "afternoon";
    return "evening";
  }

  bool initGreetings = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Health Assistant',
        ),
        systemOverlayStyle: StatusBarUtils.getStatusBarStyle(context),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: CircleAvatar(
                  radius: 20,
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
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 2),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        initGreetings == true
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Temporary chat',
                        style: textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: 20),
                      ),
                      const SizedBox(height: 100),
                      Text(
                        "Good ${_getGreeting()}, ${appUser.name}",
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "What can I help you with?",
                        textAlign: TextAlign.center,
                        style: textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 24),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
        Expanded(
          child: DashChat(
            inputOptions: InputOptions(
              inputTextStyle: theme.textTheme.bodyMedium,
              inputDecoration: InputDecoration(
                hintText: "Write a message...",
                hintStyle: theme.textTheme.bodyMedium,
                filled: true,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceVariant, // Background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
              trailing: [
                IconButton(
                  onPressed: _sendMediaMessage,
                  icon: const Icon(Icons.image),
                  tooltip: 'Send Image',
                )
              ],
              sendButtonBuilder: (onSend) => IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            currentUser: currentUser,
            onSend: (message) => _sendMessage(message,
                isShortcut: false), // Regular user message
            messages: messages,
            messageOptions: MessageOptions(
              showOtherUsersAvatar: true,
              showCurrentUserAvatar: false,
              showTime: true,
              messageDecorationBuilder:
                  (message, previousMessage, nextMessage) {
                final isCurrentUser = message.user.id == currentUser.id;
                return BoxDecoration(
                  color:
                      isCurrentUser ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isCurrentUser
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                    bottomRight: isCurrentUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                );
              },
              messageTextBuilder: (message, previousMessage, nextMessage) {
                return Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show markdown content
                      MarkdownBody(
                        data: message.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          // Paragraph
                          p: textTheme.bodySmall?.copyWith(
                            color: message.user.id == currentUser.id
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            height: 1.2,
                          ),

                          // Inline code
                          code: textTheme.bodySmall?.copyWith(
                            backgroundColor: colorScheme.surfaceVariant,
                            fontFamily: 'monospace',
                            fontSize: 14,
                            height: 1.1,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),

                          // Blockquote
                          blockquote: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                            height: 1.2,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: colorScheme.primary,
                                width: 3,
                              ),
                            ),
                          ),

                          // Headings
                          h1: textTheme.headlineLarge
                              ?.copyWith(color: colorScheme.primary),
                          h2: textTheme.headlineMedium
                              ?.copyWith(color: colorScheme.primary),
                          h3: textTheme.headlineSmall
                              ?.copyWith(color: colorScheme.primary),
                          h4: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          h5: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                          h6: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface,
                          ),

                          // Emphasis
                          strong: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                          em: textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.1,
                          ),

                          // Lists
                          listBullet: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.1,
                          ),
                          listBulletPadding: EdgeInsets.zero,
                          listIndent: 16,

                          // Tables
                          tableHead: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          tableBody: textTheme.bodySmall,
                          tableCellsPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),

                          // General spacing
                          blockSpacing: 8, // reduce gap between blocks
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            quickReplyOptions: QuickReplyOptions(
              quickReplyBuilder: (quickReply) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(quickReply.title),
                  onDeleted: () => _handleQuickReply(quickReply.title),
                  deleteIcon: const Icon(Icons.send, size: 16),
                ),
              ),
            ),
            scrollToBottomOptions: ScrollToBottomOptions(
              scrollToBottomBuilder: (scrollController) => Positioned(
                bottom: 0, // Adjust this value to position above your input
                left: MediaQuery.of(context).size.width / 2 -
                    28, // Centers the button
                child: FloatingActionButton.small(
                  onPressed: () => scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (userBookAppointmentIntent && geminiAppointment != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
            child: Column(
              children: [
                // New Conversation Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("New Conversation"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        messages.clear();
                        geminiAppointment = null;
                        userBookAppointmentIntent = false;
                        showBookButton = false;
                        initGreetings = true;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Book Appointment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.medical_services),
                    label: const Text("Book Appointment"),
                    onPressed: () {
                      print(geminiAppointment?.clinic);
                      print(geminiAppointment?.serviceCategory);
                      print(geminiAppointment?.serviceType);
                      print(geminiAppointment?.additionalInfo);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MakeAppointmentsScreen(
                            geminiAppointment!.clinic,
                            gemini_appointment: geminiAppointment,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<(double, double)?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return (position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _handleQuickReply(String text) {
    final message = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: text,
    );
    _sendMessage(message, isShortcut: false);
  }

  void startTypingAnimation() {
    typingTimer?.cancel();
    dotCount = 0;

    typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      dotCount = (dotCount + 1) % 4;
      final dots = '• ' * dotCount;

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: ' $dots',
        );
      });
    });
  }

  void stopTypingAnimation() {
    typingTimer?.cancel();
    typingTimer = null;
  }

  void _sendMessage(ChatMessage chatMessage, {bool isShortcut = false}) async {
    initGreetings = false;
    setState(() {
      if (!isShortcut) {
        messages = [chatMessage, ...messages];
      }
      messages = [
        ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: 'Typing',
        ),
        ...messages,
      ];
    });

    startTypingAnimation();

    try {
      String output;

      // --- Start: Build Conversational History ---

      // 1. The System Prompt
      final systemPrompt = """
# systemprompt
You are a helpful health assistant. Your goal is to understand the user's health needs and guide them towards booking an appropriate appointment.
You will be given the recent chat history, the latest user message, and a JSON summary of the appointment details collected so far.
Your main task is to provide a helpful, conversational response.
You should format the response using markdown for better readability when appropriate.
Avoid lengthy paragraphs and sentences.

Then, you MUST append a **complete and updated** JSON summary of the appointment details to the end of your response. The summary must be in a ```json ... ``` block and follow this exact format:
{
  "serviceCategory": "...",
  "serviceType": "...",
  "additionalInfo": "...",
  "userBookAppointmentIntent": true // or false
}

- If a detail is not yet known, use "Not specified".
- The field "userBookAppointmentIntent" must be a boolean and should be true only if the user's intent is to book an appointment, otherwise false.

# The only possible service categories (keys) and service types (list items) are:
${json.encode(allowedCategories)}
""";

      // 2. The recent conversation history (e.g., last 6 messages)
      final recentMessages = messages.skip(1).toList().reversed.take(6);
      String historyForPrompt = "# recent conversation history\n";
      if (recentMessages.isNotEmpty) {
        historyForPrompt += recentMessages.map((m) {
          final author = m.user.id == currentUser.id ? "User" : "Assistant";
          return "$author: ${m.text}";
        }).join('\n');
      } else {
        historyForPrompt += "No history yet.";
      }

      // 3. The latest user prompt
      final userPrompt = "# userprompt\n${chatMessage.text}";

      // Combine all parts into the final prompt for the model
      final enhancedPrompt = [
        systemPrompt,
        historyForPrompt,
        userPrompt
      ].join('\n\n');

      // --- End: Build Conversational History ---

      if (chatMessage.medias?.isNotEmpty ?? false) {
        final bytes = File(chatMessage.medias!.first.url).readAsBytesSync();

        final response = await gemini.textAndImage(
          text: enhancedPrompt,
          images: [bytes],
        );

        output = response?.content?.parts
                ?.whereType<TextPart>()
                .map((p) => p.text)
                .join('')
                .trim() ??
            'Sorry, I couldn\'t understand the image.';
      } else {
        final response = await gemini.prompt(
          model: "gemini-2.0-flash",
          parts: [Part.text(enhancedPrompt)],
        );

        output = (response?.output ?? 'Sorry, I didn\'t get that.').trim();
      }

      stopTypingAnimation();

      // --- DEBUGGING START ---
      print("--- Enhanced Prompt ---");
      print(enhancedPrompt);

      print("--- Gemini Raw Output ---");
      print(output);

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: removeJsonBlock(output),
        );
      });

      // Extract and update the conversation JSON for the next turn
      final newJsonText = extractJsonBlock(output);

      print("--- Extracted JSON Block ---");
      print(newJsonText);

      if (newJsonText != null) {
        setState(() {
          _parseJsonToAppointment(newJsonText);
        });
      }

      bool validAppointment = geminiAppointment != null &&
          geminiAppointment!.serviceCategory.isNotEmpty &&
          geminiAppointment!.serviceType.isNotEmpty &&
          allowedCategories.containsKey(geminiAppointment!.serviceCategory) &&
          allowedCategories[geminiAppointment!.serviceCategory]!
              .contains(geminiAppointment!.serviceType);

      // Show button if we have a valid appointment with a clinic
      if (validAppointment && geminiAppointment?.clinic != null) {
        setState(() {
          showBookButton = true;
        });
      } else {
        setState(() {
          showBookButton = false;
        });
      }
    } catch (e) {
      stopTypingAnimation();

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: '*Error occurred:* $e\n\nPlease try again.',
        );
      });
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text:
            "Please analyze this health-related image and provide detailed information using proper formatting.",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
      );
      _sendMessage(chatMessage, isShortcut: false);
    }
  }

  String? extractJsonBlock(String text) {
    final regex = RegExp(r'```json\s*([\s\S]*?)```', multiLine: true);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String removeJsonBlock(String text) {
    return text.replaceAll(RegExp(r'```json[\s\S]*?```', multiLine: true), '').trim();
  }

  void _parseJsonToAppointment(String jsonText) {
    try {
      final Map<String, dynamic> data = json.decode(jsonText);

      // Parse the intent
      userBookAppointmentIntent = data['userBookAppointmentIntent'] == true;

      () async {
        Clinic? clinic;
        final userLocation = await _getCurrentLocation();
        if (userLocation != null) {
          clinic = await FirebaseCalls().findNearestClinic(
            LatLng(userLocation.$1, userLocation.$2),
            _calculateDistance,
          );
        }
        setState(() {
          geminiAppointment = GeminiAppointment(
            clinic: clinic!,
            serviceCategory: (data['serviceCategory'] ?? '').toString() == 'Not specified' ? '' : data['serviceCategory'],
            serviceType: (data['serviceType'] ?? '').toString() == 'Not specified' ? '' : data['serviceType'],
            additionalInfo: (data['additionalInfo'] ?? '').toString() == 'Not specified' ? '' : data['additionalInfo'],
          );
        });
        print("--- Parsed Appointment JSON ---");
        print(data);
        print("--- User Book Appointment Intent ---");
        print(userBookAppointmentIntent);
      }();
    } catch (e) {
      print("Error parsing appointment JSON: $e");
    }
  }
}