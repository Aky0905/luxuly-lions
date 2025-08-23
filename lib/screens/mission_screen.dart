import 'package:flutter/material.dart';
import 'mission_detail_screen.dart'; // ✅ 상세 화면 import

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미션')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ProgressBar(),
          SizedBox(height: 12),
          _MissionTile(
            title: '남산타워 정상 정복',
            place: '남산서울타워 · 2.3km',
            difficulty: '보통',
            point: '500P',
            done: false,
            distance: '2.3km',
            timeLimit: '3시간',
            participants: '3/6',
          ),
          SizedBox(height: 8),
          _MissionTile(
            title: '한강 선셋 미션',
            place: '반포한강공원 · 1.5km',
            difficulty: '쉬움',
            point: '300P',
            done: true,
            distance: '1.5km',
            timeLimit: '2시간',
            participants: '6/6',
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.emoji_events_outlined, size: 18),
        const SizedBox(width: 6),
        Text('완료 2개', style: Theme.of(context).textTheme.bodyMedium),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: const LinearProgressIndicator(value: 0.45, minHeight: 10),
      ),
    ]);
  }
}

class _MissionTile extends StatelessWidget {
  final String title, place, difficulty, point, distance, timeLimit, participants;
  final bool done;

  const _MissionTile({
    required this.title,
    required this.place,
    required this.difficulty,
    required this.point,
    required this.done,
    required this.distance,
    required this.timeLimit,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$place • 난이도 $difficulty • 보상 $point'),
        trailing: FilledButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MissionDetailScreen(
                title: title,
                place: place.split(' · ').first,
                distance: distance,
                timeLimit: timeLimit,
                point: point,
                participants: participants,
              ),
            ));
          },
          child: Text(done ? '완료' : '참가하기'),
        ),
      ),
    );
  }
}
