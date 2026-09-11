import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/ai_message_entity.dart';
import '../../presentation/controllers/ai_chat_controller.dart';
import 'ai_state.dart';

class AIProvider extends ChangeNotifier {
  AIProvider({
    required AIChatController controller,
  }) : _controller = controller;

  final AIChatController _controller;

  AIState _state = const AIState();

  AIState get state => _state;

  StreamSubscription<String>? _subscription;

  bool get isLoading => _state.isLoading;

  bool get isStreaming => _state.isStreaming;

  List<AIMessageEntity> get messages => _state.messages;

  String? get error => _state.error;

  void _emit(
      AIState value,
      ) {
    _state = value;
    notifyListeners();
  }

  void clearError() {
    _emit(
      _state.copyWith(
        error: null,
      ),
    );
  }

  void clearConversation() {
    _subscription?.cancel();

    _emit(
      const AIState(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> sendMessage({
    required String message,
    required String userId,
    required String languageCode,
    required String conversationId,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    clearError();

    _addUserMessage(
      message,
      conversationId,
    );

    _emit(
      _state.copyWith(
        isLoading: true,
      ),
    );

    try {
      await _controller.sendMessage(
        message: message,
        userId: userId,
        languageCode: languageCode,
        conversationId: conversationId,
      );

      _emit(
        _state.copyWith(
          isLoading: false,
        ),
      );
    } catch (e) {
      _emit(
        _state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> streamMessage({
    required String message,
    required String userId,
    required String languageCode,
    required String conversationId,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    clearError();

    _addUserMessage(
      message,
      conversationId,
    );

    addAssistantPlaceholder(conversationId);

    _emit(
      _state.copyWith(
        isStreaming: true,
      ),
    );

    await _subscription?.cancel();

    _subscription = _controller
        .streamMessage(
      message: message,
      userId: userId,
      languageCode: languageCode,
      conversationId: conversationId,
    )
        .listen(
          (chunk) {
        updateLastAssistantMessage(chunk);
      },
      onDone: () {
        _emit(
          _state.copyWith(
            isStreaming: false,
          ),
        );
      },
      onError: (error) {
        _emit(
          _state.copyWith(
            isStreaming: false,
            error: error.toString(),
          ),
        );
      },
    );
  }

  void _addUserMessage(
      String message,
      String conversationId,
      ) {
    final updated = List<AIMessageEntity>.from(
      _state.messages,
    );

    updated.add(
      AIMessageEntity(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        conversationId: conversationId,
        role: AIMessageRole.user,
        content: message,
        createdAt: DateTime.now(),
      ),
    );

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  void _addAssistantMessage(
      String message,
      String conversationId,
      ) {
    final updated = List<AIMessageEntity>.from(
      _state.messages,
    );

    updated.add(
      AIMessageEntity(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        conversationId: conversationId,
        role: AIMessageRole.assistant,
        content: message,
        createdAt: DateTime.now(),
      ),
    );

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  void updateLastAssistantMessage(
      String chunk,
      ) {
    if (_state.messages.isEmpty) {
      return;
    }

    final updated = List<AIMessageEntity>.from(
      _state.messages,
    );

    final last = updated.last;

    if (last.role != AIMessageRole.assistant) {
      return;
    }

    updated[updated.length - 1] = AIMessageEntity(
      id: last.id,
      conversationId: last.conversationId,
      role: last.role,
      content: last.content + chunk,
      createdAt: last.createdAt,
    );

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  void addAssistantPlaceholder(
      String conversationId,
      ) {
    final updated = List<AIMessageEntity>.from(
      _state.messages,
    );

    updated.add(
      AIMessageEntity(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        conversationId: conversationId,
        role: AIMessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
      ),
    );

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  void removeLastMessage() {
    if (_state.messages.isEmpty) {
      return;
    }

    final updated = List<AIMessageEntity>.from(
      _state.messages,
    );

    updated.removeLast();

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  Future<void> retryLastMessage({
    required String userId,
    required String languageCode,
    required String conversationId,
  }) async {
    if (_state.messages.isEmpty) {
      return;
    }

    final lastUserMessage = _state.messages
        .where(
          (e) => e.role == AIMessageRole.user,
    )
        .lastOrNull;

    if (lastUserMessage == null) {
      return;
    }

    await sendMessage(
      message: lastUserMessage.content,
      userId: userId,
      languageCode: languageCode,
      conversationId: conversationId,
    );
  }

  bool get hasMessages =>
      _state.messages.isNotEmpty;

  bool get hasError =>
      _state.error != null;

  int get messagesCount =>
      _state.messages.length;

  AIMessageEntity? get lastMessage {
    if (_state.messages.isEmpty) {
      return null;
    }

    return _state.messages.last;
  }

  void setLoading(
      bool value,
      ) {
    _emit(
      _state.copyWith(
        isLoading: value,
      ),
    );
  }

  void setStreaming(
      bool value,
      ) {
    _emit(
      _state.copyWith(
        isStreaming: value,
      ),
    );
  }

  void setError(
      String message,
      ) {
    _emit(
      _state.copyWith(
        error: message,
      ),
    );
  }

  void addAssistantMessage(
      String message,
      String conversationId,
      ) {
    _addAssistantMessage(
      message,
      conversationId,
    );
  }

  Future<void> loadConversation(
      List<AIMessageEntity> messages,
      ) async {
    _emit(
      _state.copyWith(
        messages: List<AIMessageEntity>.from(
          messages,
        ),
      ),
    );
  }

  Future<void> addMessages(
      List<AIMessageEntity> messages,
      ) async {
    final updated = List<AIMessageEntity>.from(
      _state.messages,
    );

    updated.addAll(messages);

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  Future<void> removeMessage(
      String id,
      ) async {
    final updated = _state.messages
        .where(
          (e) => e.id != id,
    )
        .toList();

    _emit(
      _state.copyWith(
        messages: updated,
      ),
    );
  }

  Future<void> replaceMessages(
      List<AIMessageEntity> messages,
      ) async {
    _emit(
      _state.copyWith(
        messages: messages,
      ),
    );
  }

  Future<void> reset() async {
    await _subscription?.cancel();

    _subscription = null;

    _emit(
      const AIState(),
    );
  }

  Future<void> close() async {
    await _subscription?.cancel();

    _subscription = null;
  }
}
