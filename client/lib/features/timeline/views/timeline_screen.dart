import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/project.dart';
import '../../../state/data_providers.dart';
import '../../../widgets/page_header.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Portfolio timeline',
            subtitle: 'Visualise every project schedule in one place',
          ),
          Expanded(
            child: projectsAsync.when(
              data: (projects) {
                final scheduled = projects
                    .where((p) => p.startDate != null && p.endDate != null)
                    .toList();
                if (scheduled.isEmpty) {
                  return const Center(
                    child: Text(
                      'Add start and end dates to projects to see them here',
                    ),
                  );
                }
                scheduled.sort((a, b) => a.startDate!.compareTo(b.startDate!));
                final minDate = scheduled.first.startDate!;
                final maxDate = scheduled
                    .map((project) => project.endDate!)
                    .reduce((a, b) => a.isAfter(b) ? a : b);

                return ListView.separated(
                  itemCount: scheduled.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ProjectTimelineRow(
                    project: scheduled[index],
                    minDate: minDate,
                    maxDate: maxDate,
                  ),
                );
              },
              error: (error, __) =>
                  Center(child: Text('Failed to load timeline: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTimelineRow extends StatelessWidget {
  const _ProjectTimelineRow({
    required this.project,
    required this.minDate,
    required this.maxDate,
  });

  final Project project;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  Widget build(BuildContext context) {
    final totalDuration = maxDate
        .difference(minDate)
        .inHours
        .toDouble()
        .clamp(1, double.infinity);
    final startOffset =
        project.startDate!.difference(minDate).inHours.toDouble() /
        totalDuration;
    final projectDuration =
        project.endDate!.difference(project.startDate!).inHours.toDouble() /
        totalDuration;
    final formatter = DateFormat.MMMd();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${formatter.format(project.startDate!)} - ${formatter.format(project.endDate!)}',
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Positioned(
                      left: width * startOffset,
                      child: Container(
                        height: 18,
                        width: width * projectDuration,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
