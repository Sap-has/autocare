import 'package:flutter/material.dart';

class Suggestion {
  final String title;
  bool completed;
  DateTime? reminder;

  Suggestion({required this.title, this.completed = false, this.reminder});
}

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  static const List<String> _defaultTitles = [
    'Oil Change',
    'Tire Rotation',
    'Brake Inspection',
    'Engine Air Filter Replacement',
    'Transmission Fluid Check',
    'Battery Test',
  ];

  late List<Suggestion> _suggestions;

  @override
  void initState() {
    super.initState();
    _suggestions = _defaultTitles.map((title) => Suggestion(title: title)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Suggestions'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _suggestions[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  item.completed ? Icons.check_box : Icons.check_box_outline_blank,
                ),
                onPressed: () {
                  setState(() => item.completed = !item.completed);
                },
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: item.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.alarm),
                onPressed: () => _scheduleReminder(context, item, index),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _scheduleReminder(BuildContext context, Suggestion item, int id) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => item.reminder = scheduledDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder set for "${item.title}" on ${_formatDateTime(scheduledDate)}',
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}