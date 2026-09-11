import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_app_bar.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/ai_message_input.dart';
import '../widgets/ai_typing_indicator.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({
    super.key,
  });

  @override
  State<AIChatScreen> createState() =>
      _AIChatScreenState();
}

class _AIChatScreenState
    extends State<AIChatScreen> {
final TextEditingController
_messageController =
TextEditingController();

final ScrollController
_scrollController =
ScrollController();

@override
void dispose() {
_messageController.dispose();
_scrollController.dispose();
super.dispose();
}

void _scrollToBottom() {
WidgetsBinding.instance
.addPostFrameCallback((_) {
if (!_scrollController.hasClients) {
return;
}

_scrollController.animateTo(
_scrollController
.position
.maxScrollExtent,
duration: const Duration(
milliseconds: 300,
),
curve: Curves.easeOut,
);
});
}
Future<void> _sendMessage() async {
final provider =
context.read<AIProvider>();

final message =
_messageController.text.trim();

if (message.isEmpty) {
return;
}

_messageController.clear();

await provider.sendMessage(
message: message,
userId: 'current-user',
languageCode: 'en',
conversationId: 'default',
);

_scrollToBottom();
}

@override
Widget build(
BuildContext context,
) {
return Consumer<AIProvider>(
builder:
(_, provider, __) {
return Scaffold(
appBar: AIAppBar(
onClearChat:
provider.clearConversation,
),
body: SafeArea(
child: Column(
children: [
Expanded(
child: ListView.builder(
controller: _scrollController,
padding: const EdgeInsets.all(16),
itemCount: provider.messages.length,
itemBuilder: (context, index) {
return AIChatBubble(
message: provider.messages[index],
);
},
),
),
if (provider.isStreaming ||
provider.isLoading)
const AITypingIndicator(),
AIMessageInput(
controller: _messageController,
enabled: !provider.isLoading,
onSend: _sendMessage,
),
],
),
),
);
},
);
}
@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
_scrollToBottom();
});
}

@override
void didUpdateWidget(
covariant AIChatScreen oldWidget,
) {
super.didUpdateWidget(oldWidget);

_scrollToBottom();
}
@override
void didChangeDependencies() {
super.didChangeDependencies();

WidgetsBinding.instance.addPostFrameCallback((_) {
if (!mounted) {
return;
}

_scrollToBottom();
});
}
}
