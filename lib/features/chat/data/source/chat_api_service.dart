import 'package:logger/logger.dart';
import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/features/chat/data/models/chat_conversation_model.dart';
import 'package:rentverse/features/chat/data/models/chat_message_model.dart';
import 'package:rentverse/features/chat/data/models/start_chat_response_model.dart';

abstract class ChatApiService {
  Future<StartChatResponseModel> startConversation(String propertyId);
  Future<List<ChatConversationModel>> getConversations();
  Future<List<ChatMessageModel>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
}

class ChatApiServiceImpl implements ChatApiService {
  final DioClient _dioClient;
  final Logger _logger;

  ChatApiServiceImpl(this._dioClient, this._logger);

  @override
  Future<StartChatResponseModel> startConversation(String propertyId) async {
    try {
      final response = await _dioClient.post(
        '/chats/start',
        data: {'propertyId': propertyId},
      );
      _logger.i('Chat start success -> ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return StartChatResponseModel.fromJson(data);
    } catch (e) {
      _logger.e('Chat start failed', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final response = await _dioClient.get('/chats');
      _logger.i('Chat list success -> ${response.data}');
      final raw = response.data;
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      final list = data is List ? data : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatConversationModel.fromJson)
          .toList();
    } catch (e) {
      _logger.e('Chat list failed', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId) async {
    try {
      _logger.i(
        'Chat messages request roomId=$roomId path=/chats/$roomId/messages',
      );
      final response = await _dioClient.get('/chats/$roomId/messages');
      _logger.i('Chat messages success -> ${response.data}');
      final raw = response.data;
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      final list = data is List ? data : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList();
    } catch (e) {
      _logger.e('Chat messages failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    try {
      _logger.i(
        'Chat send request roomId=$roomId content=$content path=/chats/$roomId/messages',
      );
      await _dioClient.post(
        '/chats/$roomId/messages',
        data: {'content': content},
      );
      _logger.i('Chat send success');
    } catch (e) {
      _logger.e('Chat send failed', error: e);
      rethrow;
    }
  }
}
