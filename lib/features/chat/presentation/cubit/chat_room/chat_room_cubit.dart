import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/features/chat/data/models/chat_message_model.dart';
import 'package:rentverse/features/chat/data/source/chat_socket_service.dart';
import 'package:rentverse/features/chat/domain/usecase/get_messages_usecase.dart';
import 'package:rentverse/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:rentverse/features/chat/presentation/cubit/chat_room/chat_room_state.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  ChatRoomCubit(
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._socketService, {
    required this.currentUserId,
  }) : super(const ChatRoomState());

  final GetMessagesUseCase _getMessagesUseCase;
  // ignore: unused_field
  final SendMessageUseCase
  _sendMessageUseCase; // HTTP send currently unused; messages are sent via socket
  final ChatSocketService _socketService;
  final String currentUserId;

  StreamSubscription<Map<String, dynamic>>? _socketSubscription;

  Future<void> init(String roomId) async {
    emit(
      state.copyWith(
        status: ChatRoomStatus.loading,
        roomId: roomId,
        error: null,
      ),
    );

    _socketService.connect();
    _socketService.joinRoom(roomId);
    _listenSocket(roomId);

    await _loadMessages(roomId);
  }

  Future<void> _loadMessages(String roomId) async {
    try {
      final messages = await _getMessagesUseCase(
        roomId,
        currentUserId: currentUserId,
      );
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(
        state.copyWith(
          status: ChatRoomStatus.success,
          messages: messages,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatRoomStatus.failure, error: e.toString()));
    }
  }

  void _listenSocket(String roomId) {
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.messageStream.listen((raw) {
      try {
        final model = ChatMessageModel.fromJson(raw);
        final message = model.toEntity(currentUserId: currentUserId);
        if (message.roomId != roomId) return;

        final updated = [...state.messages, message]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        emit(state.copyWith(messages: updated, status: ChatRoomStatus.success));
      } catch (_) {}
    });
  }

  Future<void> sendMessage(String content) async {
    final roomId = state.roomId;
    if (roomId == null || content.trim().isEmpty) return;

    emit(state.copyWith(sending: true, error: null));
    try {
      // Send via WebSocket only (backend expects socket event, not HTTP CRUD)
      _socketService.sendMessage(roomId, content);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(sending: false));
    }
  }

  @override
  Future<void> close() {
    if (state.roomId != null) {
      _socketService.leaveRoom(state.roomId!);
    }
    _socketSubscription?.cancel();
    return super.close();
  }
}
