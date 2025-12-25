import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/notification/domain/entity/notification_response_entity.dart';
import 'package:rentverse/features/notification/domain/usecase/get_notifications_usecase.dart';
import 'package:rentverse/features/notification/domain/usecase/mark_all_notifications_read_usecase.dart';
import 'package:rentverse/features/notification/domain/usecase/mark_notification_read_usecase.dart';
import 'package:rentverse/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:rentverse/features/notification/presentation/cubit/notification_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(
        sl<GetNotificationsUseCase>(),
        sl<MarkNotificationReadUseCase>(),
        sl<MarkAllNotificationsReadUseCase>(),
      )..load(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final hasUnread = state.items.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  context.read<NotificationCubit>().markAllRead();
                },
                child: const Text('Read All'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const _NotificationBody(),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bellOff,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<NotificationCubit>().load(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 200 &&
                  scroll is ScrollUpdateNotification) {
                context.read<NotificationCubit>().loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final item = state.items[index];
                return _NotificationTile(item: item);
              },
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItemEntity item;

  @override
  Widget build(BuildContext context) {
    final createdText =
        DateFormat('dd MMM, HH:mm').format(item.createdAt.toLocal());
    final isRead = item.isRead;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: !isRead
            ? Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1)
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isRead) {
              context.read<NotificationCubit>().markRead(item.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    !isRead ? FontWeight.w700 : FontWeight.w600,
                                color:
                                    !isRead ? Colors.black87 : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: !isRead ? Colors.black87 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            createdText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          LucideIcons.bell,
          color: Colors.blue.shade600,
          size: 24,
        ),
      ),
    );
  }
}
