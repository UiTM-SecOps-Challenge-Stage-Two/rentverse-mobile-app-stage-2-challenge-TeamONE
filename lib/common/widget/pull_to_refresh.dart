import 'package:flutter/material.dart';


class ReloadDataNotification extends Notification {
  const ReloadDataNotification();
}


class PullToRefresh extends StatelessWidget {
  const PullToRefresh({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      edgeOffset: 0,
      onRefresh: () async {
        if (onRefresh != null) return await onRefresh!();

        ReloadDataNotification().dispatch(context);

        await Future.delayed(const Duration(milliseconds: 400));
      },
      child: _ScrollWrapper(child: child),
    );
  }
}


class _ScrollWrapper extends StatelessWidget {
  const _ScrollWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: true, child: child)],
    );
  }
}
