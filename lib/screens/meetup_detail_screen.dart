import 'package:flutter/material.dart';
import '../models/meetup.dart';
import '../state/meetup_state.dart';
import '../state/points_state.dart';
import '../state/coupon_state.dart';
import '../models/coupon.dart';
import 'mission_verify_screen.dart';

class MeetupDetailScreen extends StatefulWidget {
  final Meetup meetup;
  final String currentArea;

  const MeetupDetailScreen({
    super.key,
    required this.meetup,
    required this.currentArea,
  });

  @override
  State<MeetupDetailScreen> createState() => _MeetupDetailScreenState();
}

class _MeetupDetailScreenState extends State<MeetupDetailScreen> {
  late Meetup m;

  @override
  void initState() {
    super.initState();
    m = widget.meetup;
  }

  bool get _isFull => m.joined >= m.capacity;

  void _join() {
    if (_isFull) return;
    setState(() {
      MeetupState().join(m);
    });
    if (_isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모집이 완료되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('참가 완료! 현재 ${m.joined}/${m.capacity}')),
      );
    }
  }

  // 모임 인증하기
  Future<void> _verifyMeetup() async {
    final reward = m.rewardPoint; // Meetup 모델에 rewardPoint 필드가 있어야 함
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MissionVerifyScreen(
          title: m.title,
          rewardPoint: reward,
        ),
      ),
    );
    if (done == true && mounted) {
      // 포인트 적립
      PointsState().add(reward);

      // 쿠폰도 발급 (옵션)
      final now = DateTime.now();
      final code = 'MP-${now.millisecondsSinceEpoch.toString().substring(6)}';
      CouponState().addCoupon(Coupon(
        id: 'meetup-${now.millisecondsSinceEpoch}',
        title: '${m.title} 참여 리워드',
        description: '${m.location} 제휴처에서 사용 가능한 ${reward}P 쿠폰',
        issuedAt: now,
        code: code,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모임 인증 완료! +${reward}P 적립 & 쿠폰 발급')),
      );
      setState(() {});
    }
  }

  String _roughDistance() {
    final s = '${widget.currentArea}-${m.location}';
    final hash = s.codeUnits.fold<int>(0, (a, b) => (a + b) & 0xFFFF);
    final km = 0.5 + (hash % 26) / 10.0;
    return '${km.toStringAsFixed(1)}km';
  }

  String _fmt(DateTime d) {
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day} ${d.hour}:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final distance = _roughDistance();

    return Scaffold(
      appBar: AppBar(title: const Text('동네 팟 상세')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 제목 + 장소
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(m.location),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_isFull ? '모집완료' : '모집중', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 설명
          Text(m.description),
          const SizedBox(height: 12),

          // 메트릭 4개
          Row(
            children: [
              _MetricBox(title: '거리', value: distance),
              const SizedBox(width: 12),
              _MetricBox(title: '일시', value: _fmt(m.when)),
              const SizedBox(width: 12),
              _MetricBox(title: '보상', value: '${m.rewardPoint}P'),
              const SizedBox(width: 12),
              _MetricBox(title: '참가자', value: '${m.joined}/${m.capacity}'),
            ],
          ),

          const SizedBox(height: 24),

          // 액션 버튼
          FilledButton(
            onPressed: _isFull ? null : _join,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: Text(_isFull ? '모집완료' : '참가하기'),
          ),
          const SizedBox(height: 8),

          FilledButton.tonal(
            onPressed: _verifyMeetup,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('모임 인증하기'),
          ),

          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  const _MetricBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
