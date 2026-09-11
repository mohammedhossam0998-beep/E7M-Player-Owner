import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String baseUrl,
    required String token,
    void Function()? onConnected,
  }) {
    disconnect();

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({
        'token': token,
      })
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('🔌 Socket connected');
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
    });

    _socket!.connect();
  }

  void joinTeam(
      int teamId, {
        void Function(dynamic)? onResult,
      }) {
    if (_socket == null) {
      print('❌ Socket is not initialized');
      return;
    }

    if (!_socket!.connected) {
      print('⏳ Socket is not connected yet');
      return;
    }

    print('👥 Joining team:$teamId');

    _socket!.emitWithAck(
      'team:join',
      teamId,
      ack: onResult,
    );
  }

  void leaveTeam(int teamId) {
    if (_socket?.connected != true) {
      return;
    }

    _socket!.emit('team:leave', teamId);
  }

  void sendMessage(
      int teamId,
      String message, {
        void Function(dynamic)? onResult,
      }) {
    if (_socket == null || !_socket!.connected) {
      print('❌ Cannot send message: Socket is not connected');
      return;
    }

    print('📤 Sending message to team:$teamId');

    _socket!.emitWithAck(
      'team:send_message',
      {
        'teamId': teamId,
        'message': message,
      },
      ack: onResult,
    );
  }

  void onNewMessage(
      void Function(dynamic) callback,
      ) {
    _socket?.on(
      'team:new_message',
      callback,
    );
  }

  void removeNewMessageListener() {
    _socket?.off('team:new_message');
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}