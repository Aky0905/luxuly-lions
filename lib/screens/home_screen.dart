import 'package:flutter/material.dart';
import 'mission_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈'), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Text('강남구 · 서울특별시', style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.near_me_outlined, size: 18),
                label: const Text('위치 변경'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '강남구에서 모험을 시작하세요!',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: '완료한 미션', value: '12개', icon: Icons.check_circle_outline),
              _StatChip(label: '획득 포인트', value: '2,340P', icon: Icons.star_border),
              _StatChip(label: '함께한 사람', value: '48명', icon: Icons.groups_2_outlined),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('강남구 지역 미션', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              FilledButton.tonal(onPressed: () {}, child: const Text('2개')),
            ],
          ),
          const SizedBox(height: 12),

          // 카드 1: 코엑스 아쿠아리움 탐험
          _MissionCard(
            title: '코엑스 아쿠아리움 탐험',
            place: '코엑스 아쿠아리움 · 0.8km',
            difficulty: '쉬움',
            point: 400,
            badge: '할인',
            distance: '0.8km',
            timeLimit: '2시간',
            participants: '2/4',
          ),
          const SizedBox(height: 12),

          // 카드 2: 강남역 지하상가 카페 투어
          _MissionCard(
            title: '강남역 지하상가 카페 투어',
            place: '강남역 지하상가 · 1.2km',
            difficulty: '보통',
            point: 600,
            badge: '할인',
            distance: '1.2km',
            timeLimit: '3시간',
            participants: '4/6',
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final String title, place, difficulty;
  final int point;
  final String? badge;

  // 상세 화면으로 넘길 추가 정보
  final String distance, timeLimit, participants;

  const _MissionCard({
    super.key,
    required this.title,
    required this.place,
    required this.difficulty,
    required this.point,
    this.badge,
    required this.distance,
    required this.timeLimit,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(place)),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(badge!, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
          ]),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            _Metric('난이도', difficulty),
            const SizedBox(width: 12),
            _Metric('포인트', '${point}P'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MissionDetailScreen(
                    title: title,
                    place: place.split(' · ').first, // 장소만 깔끔히
                    distance: distance,
                    timeLimit: timeLimit,
                    point: '${point}P',
                    participants: participants,
                  ),
                ));
              },
              child: const Text('참가하기'),
            ),
          ])
        ]),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}
