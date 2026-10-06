import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/team_message_model.dart';
import '../providers/team_provider.dart';
import '../../../../../shared/localization/language_provider.dart';
import '../../../../../core/network/socket_service.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';

class TeamChatScreen extends StatefulWidget {
  final int teamId;

  const TeamChatScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  // ============================================================
  // INITIALIZE CHAT
  // ============================================================

  Future<void> _initializeChat() async {
    final auth = context.read<AuthController>();

    final token = auth.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await context.read<TeamProvider>().loadTeamMessages(widget.teamId);

    _socketService.connect(
      baseUrl: 'http://172.16.25.24:5000',
      token: token,
      onConnected: () {
        _socketService.joinTeam(
          widget.teamId,
          onResult: (result) {
            print('👥 Team room result: $result');
          },
        );
      },
    );

    _socketService.onNewMessage((data) {
      if (!mounted) return;

      final message = TeamMessageModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      final provider = context.read<TeamProvider>();

      provider.addIncomingMessage(message);
    });
  }

  @override
  void dispose() {
    _socketService.leaveTeam(widget.teamId);
    _socketService.removeNewMessageListener();
    _socketService.disconnect();

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    _socketService.sendMessage(
      widget.teamId,
      text,
      onResult: (result) {
        print('📨 Send result: $result');
      },
    );

    _messageController.clear();

    _scrollToBottom();
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    final currentUserId =
        context.watch<AuthController>().userId;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          t('team_chat'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TeamProvider>(
              builder: (
                  context,
                  provider,
                  _,
                  ) {
                // ------------------------------------------------
                // LOADING
                // ------------------------------------------------

                if (provider.isLoadingMessages) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ------------------------------------------------
                // ERROR
                // ------------------------------------------------

                if (provider.errorMessage != null &&
                    provider.teamMessages.isEmpty) {
                  return _ChatErrorState(
                    message: provider.errorMessage!,
                    onRetry: () {
                      provider.loadTeamMessages(
                        widget.teamId,
                      );
                    },
                  );
                }

                // ------------------------------------------------
                // EMPTY
                // ------------------------------------------------

                if (provider.teamMessages.isEmpty) {
                  return _EmptyChatState(
                    message: t('no_messages'),
                  );
                }

                // ------------------------------------------------
                // MESSAGES
                // ------------------------------------------------

                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    20,
                  ),
                  itemCount: provider.teamMessages.length,
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    final message =
                    provider.teamMessages[index];

                    final isMine =
                        currentUserId != null &&
                            message.senderId ==
                                currentUserId;

                    return _MessageBubble(
                      message: message,
                      isMine: isMine,
                    );
                  },
                );
              },
            ),
          ),

          // ------------------------------------------------------
          // MESSAGE INPUT
          // ------------------------------------------------------

          Consumer<TeamProvider>(
            builder: (
                context,
                provider,
                _,
                ) {
              return _MessageInput(
                controller: _messageController,
                isSending: provider.isSendingMessage,
                onSend: _sendMessage,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MESSAGE BUBBLE
// ============================================================

class _MessageBubble extends StatelessWidget {
  final TeamMessageModel message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final senderName =
    message.fullName?.trim().isNotEmpty == true
        ? message.fullName!
        : 'Player';

    final time = message.createdAt != null
        ? _formatTime(message.createdAt!)
        : '';

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
          MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? const Color(0xFF7CC000)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isMine ? 18 : 4,
            ),
            bottomRight: Radius.circular(
              isMine ? 4 : 18,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // SENDER NAME
            // ----------------------------------------------------

            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7CC000),
                  ),
                ),
              ),

            // ----------------------------------------------------
            // MESSAGE
            // ----------------------------------------------------

            Text(
              message.message,
              style: TextStyle(
                color: isMine
                    ? Colors.white
                    : Colors.black87,
                fontSize: 15,
                height: 1.35,
              ),
            ),

            // ----------------------------------------------------
            // TIME
            // ----------------------------------------------------

            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isMine
                        ? Colors.white70
                        : Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  static String _formatTime(
      DateTime dateTime,
      ) {
    final hour =
    dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute = dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }
}

// ============================================================
// MESSAGE INPUT
// ============================================================

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction:
                TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  filled: true,
                  fillColor:
                  Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              width: 48,
              height: 48,
              child: IconButton.filled(
                onPressed:
                isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY CHAT
// ============================================================

class _EmptyChatState extends StatelessWidget {
  final String message;

  const _EmptyChatState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF7CC000,
                ).withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: Color(0xFF7CC000),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ChatErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChatErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}