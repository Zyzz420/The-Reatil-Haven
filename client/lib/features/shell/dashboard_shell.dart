import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/data_providers.dart';
import '../../state/ui/ui_controller.dart';
import 'nav_item.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_nav_bar.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key, required this.child});

  final Widget child;

  static const _navItems = [
    NavItem(label: 'Home', route: '/', icon: Icons.dashboard_outlined),
    NavItem(label: 'Timeline', route: '/timeline', icon: Icons.timeline),
    NavItem(label: 'Search', route: '/search', icon: Icons.search),
    NavItem(label: 'Users', route: '/users', icon: Icons.person_outline),
    NavItem(label: 'Teams', route: '/teams', icon: Icons.people_outline),
    NavItem(
      label: 'Settings',
      route: '/settings',
      icon: Icons.settings_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final projectsAsync = ref.watch(projectsProvider);
    final projects = projectsAsync.valueOrNull ?? const [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        return Scaffold(
          key: scaffoldKey,
          drawer: isMobile
              ? Drawer(
                  child: SafeArea(
                    child: DashboardSidebar(
                      navItems: _navItems,
                      projects: projects,
                      onItemSelected: () =>
                          scaffoldKey.currentState?.closeDrawer(),
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  DashboardSidebar(navItems: _navItems, projects: projects),
                Expanded(
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) => DashboardTopBar(
                          onMenuPressed: () {
                            if (isMobile) {
                              Scaffold.of(context).openDrawer();
                            } else {
                              ref
                                  .read(uiControllerProvider.notifier)
                                  .toggleSidebar();
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: projectsAsync.when(
                            data: (_) => child,
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, __) => Center(
                              child: Text('Failed to load projects: $error'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
