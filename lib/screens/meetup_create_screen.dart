import 'package:flutter/material.dart';
import '../models/meetup.dart';

class MeetupCreateScreen extends StatefulWidget {
  const MeetupCreateScreen({super.key});

  @override
  State<MeetupCreateScreen> createState() => _MeetupCreateScreenState();
}

class _MeetupCreateScreenState extends State<MeetupCreateScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _loc = TextEditingController(text: '강남역 근처');
  DateTime _when = DateTime.now().add(const Duration(hours: 2));
  int _capacity = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모임 만들기')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: '모임 제목')),
          const SizedBox(height: 8),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: '소개/설명')),
          const SizedBox(height: 8),
          TextField(controller: _loc, decoration: const InputDecoration(labelText: '장소/만남 위치')),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('일시'),
            subtitle: Text(_when.toString()),
            trailing: OutlinedButton(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _when,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
                  if (t != null) {
                    setState(() {
                      _when = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    });
                  }
                }
              },
              child: const Text('변경'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('정원'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _capacity,
                items: const [4, 6, 8, 10, 12]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e명')))
                    .toList(),
                onChanged: (v) => setState(() => _capacity = v ?? _capacity),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_title.text.trim().isEmpty) return;
              final m = Meetup(
                title: _title.text.trim(),
                description: _desc.text.trim(),
                when: _when,
                location: _loc.text.trim(),
                capacity: _capacity,
              );
              Navigator.of(context).pop(m);
            },
            child: const Text('모임 생성'),
          ),
        ],
      ),
    );
  }
}
