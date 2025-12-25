import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:rentverse/features/chat/data/models/chat_message_model.dart';
import 'package:rentverse/features/chat/data/source/chat_socket_service.dart';
import 'package:rentverse/features/chat/domain/entity/chat_conversation_entity.dart';
import 'package:rentverse/features/chat/domain/usecase/get_conversations_usecase.dart';
import 'package:rentverse/features/chat/presentation/cubit/conversation_list/conversation_list_state.dart';
import 'package:rentverse/core/services/notification_service.dart';

class ConversationListCubit extends Cubit<ConversationListState> {
  ConversationListCubit(
    this._getConversations,
    this._socketService,
    this._notificationService,
  ) : super(const ConversationListState()) {

    try {
      _socketService.connect();
    } catch (_) {}

    _socketSubscription = _socketService.messageStream.listen((raw) {
      _handleIncoming(raw);
    });


    _notificationSubscription = _notificationService.chatMessageStream.listen(
      (data) => _handleIncoming(data),
    );
  }

  final GetConversationsUseCase _getConversations;
  final ChatSocketService _socketService;
  final NotificationService _notificationService;

  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  void markAsRead(String roomId) {
    final updated = state.conversations.map((c) {
      if (c.id == roomId && c.unreadCount > 0) {
        return ChatConversationEntity(
          id: c.id,
          propertyId: c.propertyId,
          propertyTitle: c.propertyTitle,
          propertyCity: c.propertyCity,
          otherUserName: c.otherUserName,
          otherUserAvatar: c.otherUserAvatar,
          lastMessage: c.lastMessage,
          lastMessageAt: c.lastMessageAt,
          unreadCount: 0,
        );
      }
      return c;
    }).toList();

    emit(state.copyWith(conversations: updated));
  }

  Future<void> load() async {
    emit(state.copyWith(status: ConversationListStatus.loading, error: null));
    try {
      final conversations = await _getConversations();
      emit(
        state.copyWith(
          status: ConversationListStatus.success,
          conversations: conversations,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConversationListStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    _notificationSubscription?.cancel();
    return super.close();
  }

  void _handleIncoming(Map<String, dynamic> raw) {
    try {
      final msg = ChatMessageModel.fromJson(raw);
      final roomId = msg.roomId;
      final content = msg.content;
      final createdAt = msg.createdAt;

      var updated = false;
      final updatedList = state.conversations.map((c) {
        if (c.id == roomId) {
          updated = true;
          return ChatConversationEntity(
            id: c.id,
            propertyId: c.propertyId,
            propertyTitle: c.propertyTitle,
            propertyCity: c.propertyCity,
            otherUserName: c.otherUserName,
            otherUserAvatar: c.otherUserAvatar,
            lastMessage: content,
            lastMessageAt: createdAt,
            unreadCount: c.unreadCount + 1,
          );
        }
        return c;
      }).toList();

      if (updated) {

        updatedList.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
        emit(state.copyWith(conversations: updatedList));
      } else {



        unawaited(load());
      }
    } catch (_) {}
  }
}
