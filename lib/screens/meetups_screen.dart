import 'package:flutter/material.dart';
import '../state/meetup_state.dart';
import '../models/meetup.dart';
import 'meetup_create_screen.dart';
import 'meetup_detail_screen.dart'; //

class MeetupsScreen extends StatefulWidget {
  final String currentArea; // 홈에서 넘길 수 있게 기본값
  const MeetupsScreen({super.key, this.currentArea = '강남구 · 서울특별시'});

  @override
  State<MeetupsScreen> createState() => _MeetupsScreenState();
}

class _MeetupsScreenState extends State<MeetupsScreen> {
  @override
  Widget build(BuildContext context) {
    final items = MeetupState().meetups;
    return Scaffold(
      appBar: AppBar(title: const Text('동네 팟 찾기')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<Meetup>(
            MaterialPageRoute(builder: (_) => const MeetupCreateScreen()),
          );
          if (created != null) {
            setState(() => MeetupState().add(created));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('모임이 생성되었습니다.')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('모임 만들기'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final m = items[i];
          final full = m.joined >= m.capacity;
          return Card(
            child: ListTile(
              title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${m.location} • ${_fmt(m.when)}\n${m.description}'),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(full ? '모집완료' : '${m.joined}/${m.capacity} 참여'),
              ),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MeetupDetailScreen(
                    meetup: m,
                    currentArea: widget.currentArea,
                  ),
                ));
                // 상세에서 참가 후 돌아오면 카운트 업데이트 반영
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  String _fmt(DateTime d) {
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day} ${d.hour}:$mm';
  }
}
