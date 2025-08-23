import 'package:flutter/material.dart';
import '../state/user_progress.dart';
import 'mission_detail_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});
  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = UserProgress();

    return Scaffold(
      appBar: AppBar(title: const Text('미션')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ 상단 요약 카드들
          Row(
            children: [
              _StatCard(label: '완료한 미션', value: '${progress.completed}개', icon: Icons.emoji_events_outlined),
              const SizedBox(width: 12),
              _StatCard(label: '획득 포인트', value: '${progress.points}P', icon: Icons.star_border),
            ],
          ),
          const SizedBox(height: 16),

          // 진행중인 미션 (데모용 2개)
          _MissionTile(
            title: '남산타워 정상 정복',
            place: '남산서울타워 · 2.3km',
            difficulty: '보통',
            point: '500P',
          ),
          const SizedBox(height: 8),
          _MissionTile(
            title: '한강 선셋 미션',
            place: '반포한강공원 · 1.5km',
            difficulty: '쉬움',
            point: '300P',
            done: true, // 데모: 완료됨 표시
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final String title, place, difficulty, point;
  final bool done;
  const _MissionTile({
    required this.title,
    required this.place,
    required this.difficulty,
    required this.point,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('$place • 난이도 $difficulty • 보상 $point'),
          trailing: FilledButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MissionDetailScreen(
                  title: title,
                  place: place.split(' · ').first,
                  distance: place.contains('·') ? place.split('·').last.trim() : '',
                  timeLimit: difficulty == '보통' ? '3시간' : '2시간',
                  point: point,
                  participants: done ? '6/6' : '3/6',
                ),
              ));
            },
            child: const Text('자세히'),
          ),
        ),
      ),
    );
  }
}
