import 'dart:async';
import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:healthify/custom_widgets/bottom_navigation_bar.dart';
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HealthAssistant extends StatefulWidget {
  const HealthAssistant({super.key});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Assistant',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: 2),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DashChat(
      inputOptions: InputOptions(
        inputTextStyle: theme.textTheme.bodyMedium,
        inputDecoration: InputDecoration(
          hintText: "Write a message...",
          hintStyle: theme.textTheme.bodyMedium,
          filled: true,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          fillColor:
              Theme.of(context).colorScheme.surfaceVariant, // Background color
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
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(
        showOtherUsersAvatar: true,
        showCurrentUserAvatar: false,
        showTime: true,
        // Enhanced message options for better markdown rendering
        messageDecorationBuilder: (message, previousMessage, nextMessage) {
          return BoxDecoration(
            color: message.user.id == currentUser.id
                ? colorScheme.primary.withOpacity(0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          );
        },
        // Custom text builder for better markdown handling
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
                    p: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    code: textTheme.bodySmall?.copyWith(
                      backgroundColor: colorScheme.surfaceVariant,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    blockquote: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colorScheme.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    h1: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                    h2: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                    h3: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
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
                    strong: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    em: textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    listBullet: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    tableHead: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    tableBody: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Enhanced quick reply options for health-related suggestions
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
      scrollToBottomOptions: ScrollToBottomOptions(),
    );
  }

  void _handleQuickReply(String text) {
    final message = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: text,
    );
    _sendMessage(message);
  }

  void startTypingAnimation() {
    typingTimer?.cancel();
    dotCount = 0;

    typingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      dotCount = (dotCount + 1) % 4;
      final dots = ' .' * dotCount;

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: 'Typing$dots',
        );
      });
    });
  }

  void stopTypingAnimation() {
    typingTimer?.cancel();
    typingTimer = null;
  }

  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];

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

      // Enhanced prompt for better health-related responses with markdown
      String enhancedPrompt = chatMessage.text;
      if (chatMessage.medias?.isEmpty ?? true) {
        enhancedPrompt = """
You are a helpful health assistant. Please provide a comprehensive response using markdown formatting where appropriate. Use:
- **Bold** for important terms
- *Italic* for emphasis
- ## Headers for different sections
- - Bullet points for lists
- > Blockquotes for important notes
- `code` for medical terms or dosages

User question: ${chatMessage.text}

Please format your response with proper markdown for better readability.
""";
      }

      // Check if user sent an image
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
          parts: [Part.text(enhancedPrompt)],
        );

        output = (response?.output ?? 'Sorry, I didn\'t get that.').trim();
      }

      stopTypingAnimation();

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: output,
        );
      });
    } catch (e) {
      stopTypingAnimation();

      setState(() {
        messages[0] = ChatMessage(
          user: geminiUser,
          createdAt: messages[0].createdAt,
          text: '**Error occurred:** $e\n\nPlease try again.',
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
      _sendMessage(chatMessage);
    }
  }

  @override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }
}
