import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/enums.dart';
import '../../data/models/task_input.dart';
import '../../state/data_providers.dart';

Future<void> showTaskFormDialog(BuildContext context, {int? projectId}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(child: _TaskFormDialog(projectId: projectId)),
  );
}

class _TaskFormDialog extends ConsumerStatefulWidget {
  const _TaskFormDialog({this.projectId});

  final int? projectId;

  @override
  ConsumerState<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<_TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _pointsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.backlog;
  TaskStatus _status = TaskStatus.toDo;
  bool _isSubmitting = false;

  int? _selectedProjectId;
  int? _authorId;
  int? _assigneeId;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({
    required DateTime? initial,
    required ValueSetter<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null || _authorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project and author are required')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final input = TaskInput(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text,
      projectId: _selectedProjectId!,
      authorUserId: _authorId!,
      assignedUserId: _assigneeId,
      points: int.tryParse(_pointsController.text.trim()),
      priority: _priority,
      status: _status,
      startDate: _startDate,
      dueDate: _dueDate,
    );

    try {
      await ref.read(taskMutationsProvider).createTask(input);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create task: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final usersAsync = ref.watch(usersProvider);

    final projects = projectsAsync.valueOrNull ?? [];
    final users = usersAsync.valueOrNull ?? [];

    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }
    if (_authorId == null && users.isNotEmpty) {
      _authorId = users.first.userId;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Task',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _selectedProjectId,
                decoration: const InputDecoration(labelText: 'Project'),
                items: projects
                    .map(
                      (project) => DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedProjectId = value;
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: TaskStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _status = value!;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: TaskPriority.values
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _priority = value!;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'Start date',
                      date: _startDate,
                      onTap: () => _selectDate(
                        initial: _startDate,
                        onSelected: (value) => setState(() {
                          _startDate = value;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateButton(
                      label: 'Due date',
                      date: _dueDate,
                      onTap: () => _selectDate(
                        initial: _dueDate,
                        onSelected: (value) => setState(() {
                          _dueDate = value;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _authorId,
                      decoration: const InputDecoration(labelText: 'Author'),
                      items: users
                          .map(
                            (user) => DropdownMenuItem(
                              value: user.userId,
                              child: Text(user.username),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        _authorId = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: _assigneeId,
                      decoration: const InputDecoration(labelText: 'Assignee'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        ...users.map(
                          (user) => DropdownMenuItem(
                            value: user.userId,
                            child: Text(user.username),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _assigneeId = value;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Story points'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = date != null
        ? MaterialLocalizations.of(context).formatShortDate(date!)
        : 'Select date';
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }
}
