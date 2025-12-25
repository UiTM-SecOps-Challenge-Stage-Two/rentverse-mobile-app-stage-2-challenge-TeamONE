import 'dart:async';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:rentverse/core/constant/api_urls.dart';

class ChatSocketService {
  ChatSocketService(this._logger, this._preferences);

  final Logger _logger;
  final SharedPreferences _preferences;


  static const String _url = 'wss://rvapi.ilhamdean.cloud';


  static const String joinRoomEvent = 'JOIN_ROOM';
  static const String leaveRoomEvent = 'LEAVE_ROOM';
  static const String sendMessageEvent = 'SEND_MESSAGE';
  static const String newMessageEvent = 'NEW_MESSAGE';

  io.Socket? _socket;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  bool get isConnected => _socket?.connected == true;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect() {
    if (isConnected) {
      _logger.i('Chat socket already connected');
      return;
    }

    final token = _preferences.getString(ApiConstants.tokenKey);

    _logger.i('Connecting chat socket...');

    _socket = io.io(
      _url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .setPath('/socket.io/')
          .setExtraHeaders(
            token != null && token.isNotEmpty
                ? {'Authorization': 'Bearer $token'}
                : <String, dynamic>{},
          )
          .build(),
    );

    _socket?.onConnect((_) => _logger.i('Chat socket connected'));
    _socket?.onDisconnect((_) => _logger.w('Chat socket disconnected'));
    _socket?.onError((data) => _logger.e('Chat socket error: $data'));
    _socket?.onConnectError(
      (data) => _logger.e('Chat socket connect error: $data'),
    );

    _socket?.on(newMessageEvent, (data) {
      _logger.i('Chat socket new message event: $data');
      if (data is Map<String, dynamic>) {
        _messageController.add(data);
      } else if (data is Map) {
        _messageController.add(Map<String, dynamic>.from(data));
      } else {
        _logger.w('Chat socket unknown message payload: ${data.runtimeType}');
      }
    });
  }

  void joinRoom(String roomId) {
    _logger.i('Chat socket join room: $roomId');
    _socket?.emit(joinRoomEvent, {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    _logger.i('Chat socket leave room: $roomId');
    _socket?.emit(leaveRoomEvent, {'roomId': roomId});
  }

  void sendMessage(String roomId, String content) {
    _logger.i('Chat socket send message room=$roomId content=$content');
    _socket?.emit(sendMessageEvent, {'roomId': roomId, 'content': content});
  }

  void disconnect() {
    _logger.i('Chat socket disconnect');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
