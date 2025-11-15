import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/project.dart';
import '../../../state/ui/ui_controller.dart';
import '../nav_item.dart';

class DashboardSidebar extends ConsumerWidget {
  const DashboardSidebar({
    super.key,
    required this.navItems,
    required this.projects,
    this.onItemSelected,
  });

  final List<NavItem> navItems;
  final List<Project> projects;
  final VoidCallback? onItemSelected;

  static const _priorityItems = [
    NavItem(
      label: 'Urgent',
      route: '/priority/urgent',
      icon: Icons.error_outline,
      matchPrefix: true,
    ),
    NavItem(
      label: 'High',
      route: '/priority/high',
      icon: Icons.shield_outlined,
      matchPrefix: true,
    ),
    NavItem(
      label: 'Medium',
      route: '/priority/medium',
      icon: Icons.priority_high,
      matchPrefix: true,
    ),
    NavItem(
      label: 'Low',
      route: '/priority/low',
      icon: Icons.low_priority,
      matchPrefix: true,
    ),
    NavItem(
      label: 'Backlog',
      route: '/priority/backlog',
      icon: Icons.layers_outlined,
      matchPrefix: true,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiControllerProvider);

    return uiState.when(
      data: (state) {
        if (state.isSidebarCollapsed) {
          return const SizedBox.shrink();
        }
        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(
                  context,
                ).dividerColor.withAlpha((0.1 * 255).round()),
              ),
            ),
          ),
          child: Column(
            children: [
              _SidebarHeader(
                onCollapse: () =>
                    ref.read(uiControllerProvider.notifier).toggleSidebar(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    ...navItems.map(
                      (item) =>
                          _SidebarTile(item: item, onNavigate: onItemSelected),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Divider(),
                    ),
                    _SidebarSectionTitle(title: 'Projects'),
                    if (projects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: Text('No projects yet'),
                      )
                    else
                      ...projects.map(
                        (project) => _SidebarTile(
                          item: NavItem(
                            label: project.name,
                            route: '/projects/${project.id}',
                            icon: Icons.work_outline,
                            matchPrefix: true,
                          ),
                          dense: true,
                          onNavigate: onItemSelected,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _SidebarSectionTitle(title: 'Priority'),
                    ..._priorityItems.map(
                      (item) => _SidebarTile(
                        item: item,
                        dense: true,
                        onNavigate: onItemSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox(width: 280),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.onCollapse});

  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Edlist',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onCollapse,
            icon: const Icon(Icons.close),
            tooltip: 'Collapse sidebar',
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, this.dense = false, this.onNavigate});

  final NavItem item;
  final bool dense;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = GoRouterState.of(context).uri.toString();
    final isActive = item.matchPrefix
        ? location.startsWith(item.route)
        : location == item.route;

    return ListTile(
      dense: dense,
      leading: Icon(item.icon),
      title: Text(item.label),
      selected: isActive,
      onTap: () {
        if (!isActive) {
          router.go(item.route);
        }
        onNavigate?.call();
      },
    );
  }
}
