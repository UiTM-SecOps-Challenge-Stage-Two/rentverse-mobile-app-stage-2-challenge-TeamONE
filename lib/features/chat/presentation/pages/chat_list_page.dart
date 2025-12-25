import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentverse/common/bloc/auth/auth_cubit.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/chat/domain/usecase/get_conversations_usecase.dart';
import 'package:rentverse/features/chat/data/source/chat_socket_service.dart';
import 'package:rentverse/core/services/notification_service.dart';
import 'package:rentverse/features/chat/domain/entity/chat_conversation_entity.dart';
import 'package:rentverse/features/chat/presentation/cubit/conversation_list/conversation_list_cubit.dart';
import 'package:rentverse/features/chat/presentation/cubit/conversation_list/conversation_list_state.dart';
import 'package:rentverse/features/chat/presentation/pages/chat_room_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ChatFilter { all, unread, read }

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key, required this.isLandlord});

  final bool isLandlord;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  ChatFilter _selectedFilter = ChatFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ConversationListCubit(sl<GetConversationsUseCase>(),
            sl<ChatSocketService>(), sl<NotificationService>())
          ..load(),
        child: Scaffold(
            appBar: AppBar(
                title: Text(widget.isLandlord ? 'Chat' : 'Chat'),
                centerTitle: true,
                elevation: 0,
                surfaceTintColor: Colors.white),
            body: BlocBuilder<ConversationListCubit, ConversationListState>(
                builder: (context, state) {
              if (state.status == ConversationListStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ConversationListStatus.failure) {
                return Center(
                    child: Text(state.error ?? 'Failed to load chats'));
              }

              final filtered = _filterChats(state.conversations);

              return SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ChatSearchBar(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                onFilterTap: () {}),
                            const SizedBox(height: 16),
                            _FilterRow(
                                selected: _selectedFilter,
                                onSelected: (value) {
                                  setState(() => _selectedFilter = value);
                                }),
                            const SizedBox(height: 12),
                            Expanded(
                                child: filtered.isEmpty
                                    ? const Center(
                                        child: Text('Belum ada percakapan'))
                                    : ListView.separated(
                                        itemCount: filtered.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final conversation = filtered[index];
                                          return _ChatTile(
                                              conversation: conversation);
                                        }))
                          ])));
            })));
  }

  List<ChatConversationEntity> _filterChats(
      List<ChatConversationEntity> conversations) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = conversations.where((c) {
      final matchesQuery = query.isEmpty ||
          c.otherUserName.toLowerCase().contains(query) ||
          c.propertyTitle.toLowerCase().contains(query) ||
          c.lastMessage.toLowerCase().contains(query);


      final hasUnread = c.unreadCount > 0;

      switch (_selectedFilter) {
        case ChatFilter.all:
          return matchesQuery;
        case ChatFilter.unread:
          return matchesQuery && hasUnread;
        case ChatFilter.read:
          return matchesQuery && !hasUnread;
      }
    }).toList();

    return filtered;
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.conversation});

  final ChatConversationEntity conversation;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('hh:mm a').format(conversation.lastMessageAt);
    final showUnreadDot = conversation.unreadCount > 0;

    return GestureDetector(
        onTap: () {
          final authState = context.read<AuthCubit>().state;
          if (authState is! Authenticated) return;

          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatRoomPage(
                  roomId: conversation.id,
                  otherUserName: conversation.otherUserName,
                  otherUserAvatar: conversation.otherUserAvatar,
                  propertyTitle: conversation.propertyTitle,
                  currentUserId: authState.user.id)));

          context.read<ConversationListCubit>().markAsRead(conversation.id);
        },
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                  radius: 26,
                  backgroundImage: conversation.otherUserAvatar != null &&
                          conversation.otherUserAvatar!.isNotEmpty
                      ? NetworkImage(conversation.otherUserAvatar!)
                      : null,
                  child: conversation.otherUserAvatar == null ||
                          conversation.otherUserAvatar!.isEmpty
                      ? Text(
                          conversation.otherUserName.isNotEmpty
                              ? conversation.otherUserName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.w700))
                      : null),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(conversation.otherUserName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13))
                  ])),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(timeLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                if (showUnreadDot)
                  Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle))
              ])
            ])));
  }
}

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                const _GradientIcon(LucideIcons.search, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                        onChanged: onChanged))
              ]))),
      const SizedBox(width: 10),
      GestureDetector(
          onTap: onFilterTap,
          child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  gradient: customLinearGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(LucideIcons.sliders, color: Colors.white)))
    ]);
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});

  final ChatFilter selected;
  final ValueChanged<ChatFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {
      ChatFilter.all: 'All Chat',
      ChatFilter.unread: 'Unread Chat',
      ChatFilter.read: 'Read Chat',
    };

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ChatFilter.values.map((filter) {
          final isActive = filter == selected;
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                  label: Text(labels[filter]!),
                  selected: isActive,
                  onSelected: (_) => onSelected(filter),
                  selectedColor: const Color(0xFF00E0C3),
                  labelStyle: TextStyle(
                      color: isActive ? Colors.white : appPrimaryColor,
                      fontWeight: FontWeight.w700),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: isActive
                              ? Colors.transparent
                              : Colors.grey.shade300)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap));
        }).toList());
  }
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon(this.icon, {required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        shaderCallback: (bounds) =>
            customLinearGradient.createShader(Rect.fromLTWH(0, 0, size, size)),
        child: Icon(icon, size: size, color: Colors.white));
  }
}
