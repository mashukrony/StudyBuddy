import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/priority_picker.dart';
import '../../shared/services/notifications_service.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;
  const EditTaskPage({super.key, required this.taskId});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _priority = 3;
  String _taskType = 'assignment';
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskData() async {
    final doc = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final dueDate = (data['dueDate'] as Timestamp).toDate();
      setState(() {
        _titleController.text = data['title'];
        _descController.text = data['description'] ?? '';
        _dueDate = dueDate;
        _dueTime = TimeOfDay.fromDateTime(dueDate);
        _priority = data['priority'];
        _taskType = data['type'];
        _remindersEnabled = data['reminders']['enabled'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: 'Task Title',
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descController,
                  label: 'Description (Optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildDateTimePicker(),
                const SizedBox(height: 16),
                _buildTaskTypeDropdown(),
                const SizedBox(height: 16),
                PriorityPicker(
                  currentPriority: _priority,
                  onChanged: (value) => setState(() => _priority = value),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Reminders'),
                  value: _remindersEnabled,
                  onChanged: (value) => setState(() => _remindersEnabled = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateTask,
                  child: const Text('Update Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: Text(_dueDate == null
              ? 'Select Due Date'
              : DateFormat('MMM dd, yyyy').format(_dueDate!)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _dueDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _dueDate = date);
            }
          },
        ),
        if (_dueDate != null)
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_dueTime == null
                ? 'Select Time'
                : _dueTime!.format(context)),
            onTap: _selectTime,
          ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _dueTime = pickedTime);
    }
  }

  DateTime get _combinedDateTime {
    if (_dueDate == null) throw Exception('Date not selected');
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime?.hour ?? 0,
      _dueTime?.minute ?? 0,
    );
  }

  Widget _buildTaskTypeDropdown() {
    const types = ['exam', 'assignment', 'homework'];
    return DropdownButtonFormField<String>(
      value: _taskType,
      items: types.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.capitalize()),
        );
      }).toList(),
      onChanged: (value) => setState(() => _taskType = value!),
      decoration: const InputDecoration(
        labelText: 'Task Type',
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({
            'title': _titleController.text,
            'description': _descController.text,
            'type': _taskType,
            'dueDate': Timestamp.fromDate(_combinedDateTime),
            'priority': _priority,
            'reminders': {
              'enabled': _remindersEnabled,
              'frequency': 'daily',
              'nextAlert': _calculateNextAlert(),
            },
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (_remindersEnabled) {
        await NotificationService.cancelNotification(widget.taskId);
        await NotificationService.scheduleNotification(
          _combinedDateTime,
          _titleController.text,
          widget.taskId,
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  Timestamp _calculateNextAlert() {
    final now = DateTime.now();
    if (_combinedDateTime.isBefore(now)) {
      return Timestamp.now();
    }
    return Timestamp.fromDate(_combinedDateTime);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}