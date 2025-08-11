import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthify/models/appointment.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/models/gemini_appointment.dart';
import 'package:healthify/screens/make_appointments_screen.dart';
import 'package:healthify/widgets/bottom_navigation_bar.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:healthify/screens/clinics_screen.dart';

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
        if (showBookButton && geminiAppointment != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: SizedBox(
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

      String enhancedPrompt = chatMessage.text;
      if (chatMessage.medias?.isEmpty ?? true) {
        enhancedPrompt = """
# systemprompt
You are a helpful health assistant. Please provide a comprehensive response using markdown formatting where appropriate. 
You should always aim to choose the most appropriate category and service type for the user's needs.

After your answer, provide a JSON summary with:
{
  "serviceCategory": "",
  "serviceType": "",
  "additionalInfo": "insert symptoms etc."
}

# the only possible service category (keys) and types (list items) (no other options)
{
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
}

# userprompt
${chatMessage.text}
""";
      }

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

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: removeJsonBlock(output),
        );
      });

      final summary = extractSummaryJson(output);
      bool validSummary = false;
      if (summary != null && isValidGeminiSummary(summary)) {
        validSummary = true;
        final userLocation = await _getCurrentLocation();
        if (userLocation != null) {
          final Clinic? nearestClinic = await FirebaseCalls().findNearestClinic(
            LatLng(userLocation.$1, userLocation.$2),
            _calculateDistance,
          );
          if (nearestClinic != null) {
            geminiAppointment = GeminiAppointment(
              clinic: nearestClinic,
              serviceCategory: summary['serviceCategory'] ?? summary['service_category'] ?? '',
              serviceType: summary['serviceType'] ?? summary['service_type'] ?? '',
              additionalInfo: summary['additionalInfo'] ?? summary['additional_info'] ?? '',
            );
          }
        }
      }

      if (messages.where((m) => m.user.id == currentUser.id).length > 1 && geminiAppointment != null && validSummary) {
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

  @override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }
}

Map<String, dynamic>? extractSummaryJson(String text) {
  final regex = RegExp(r'```json\s*([\s\S]*?)```', multiLine: true);
  final match = regex.firstMatch(text);
  if (match != null) {
    try {
      return json.decode(match.group(1)!);
    } catch (_) {}
  }
  return null;
}

String removeJsonBlock(String text) {
  return text.replaceAll(RegExp(r'```json[\s\S]*?```', multiLine: true), '').trim();
}

bool isValidGeminiSummary(Map<String, dynamic> summary) {
  final category = summary['serviceCategory'] ?? summary['service_category'] ?? '';
  final type = summary['serviceType'] ?? summary['service_type'] ?? '';
  if (!allowedCategories.containsKey(category)) return false;
  if (!allowedCategories[category]!.contains(type)) return false;
  return true;
}
