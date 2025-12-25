

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/widget/pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:rentverse/common/colors/custom_color.dart';

import '../bloc/navigation/navigation_cubit.dart';

class NavigationContainer extends StatefulWidget {
  final List<Widget>? pages;
  final List<BottomNavigationBarItem>? items;
  final int initialIndex;

  const NavigationContainer({
    super.key,
    this.pages,
    this.items,
    this.initialIndex = 0,
  });

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  late List<int> _reloadTicks;

  @override
  void initState() {
    super.initState();
    final count = (widget.pages!).length;
    _reloadTicks = List<int>.filled(count, 0, growable: true);
  }

  @override
  void didUpdateWidget(covariant NavigationContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = (widget.pages!).length;
    if (newCount != _reloadTicks.length) {
      _reloadTicks = List<int>.filled(newCount, 0, growable: true);
    }
  }

  Future<void> _restartPage(int index) async {
    setState(() => _reloadTicks[index]++);

    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(initialIndex: widget.initialIndex),
      child: Scaffold(
        body: _buildBody(widget.pages, _reloadTicks, _restartPage),
        bottomNavigationBar: _buildBottomNavigationBar(context, widget.items),
      ),
    );
  }
}

Widget _buildBody(
  List<Widget>? pages,
  List<int> reloadTicks,
  Future<void> Function(int) restartPage,
) {
  return BlocBuilder<NavigationCubit, int>(
    builder: (context, index) {
      final resolvedPages = pages!;

      final wrapped = <Widget>[];
      for (var i = 0; i < resolvedPages.length; i++) {
        final page = resolvedPages[i];
        wrapped.add(
          PullToRefresh(
            onRefresh: () => restartPage(i),
            child: KeyedSubtree(
              key: ValueKey('nav_page_${i}_${reloadTicks[i]}'),
              child: page,
            ),
          ),
        );
      }

      return IndexedStack(index: index, children: wrapped);
    },
  );
}


Widget _buildBottomNavigationBar(
  BuildContext context,
  List<BottomNavigationBarItem>? items,
) {
  return BlocBuilder<NavigationCubit, int>(
    builder: (context, index) {
      final barItems = items ??
          const [
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(LucideIcons.user), label: 'Profile'),
          ];
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: (i) => context.read<NavigationCubit>().updateIndex(i),
          selectedItemColor: appPrimaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: barItems,
        ),
      );
    },
  );
}

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const GradientIcon({super.key, required this.icon, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return customLinearGradient.createShader(
          Rect.fromLTWH(0, 0, size, size),
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
