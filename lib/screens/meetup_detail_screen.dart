import 'package:flutter/material.dart';
import '../models/meetup.dart';
import '../state/meetup_state.dart';
import '../state/points_state.dart';
import '../state/coupon_state.dart';
import '../models/coupon.dart';
import 'mission_verify_screen.dart';

// Party 모델 + 대기실 화면
import '../models/party.dart';
import 'waiting_room_screen.dart';

// ✅ 정원 꽉 찼을 때 채팅 시작하기 버튼으로 이동
import 'chat_room_screen.dart';

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

  // Meetup -> Party 매핑 (대기실 화면용)
  Party _toParty(Meetup mm) {
    final people = <Participant>[];

    // 현재 joined 수 기준 더미 참가자 + '나' 삽입
    final others = (mm.joined > 0) ? mm.joined - 1 : 0;
    for (var i = 0; i < others; i++) {
      people.add(Participant(name: '참가자${i + 1}', level: 10 + i, ready: false));
    }
    people.add(Participant(name: '나', level: 15, ready: false));

    return Party(
      id: mm.id?.toString() ?? 'meetup-${mm.hashCode}',
      title: mm.title,
      place: mm.location,
      dateTime: mm.when,
      capacity: mm.capacity,
      joined: mm.joined,
      people: people,
    );
  }

  void _join() {
    if (_isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정원이 가득 찼습니다.')),
      );
      return;
    }

    // 1) 참가 처리 (전역 상태)
    setState(() {
      MeetupState().join(m); // m.joined 증가
    });

    // 2) 대기실로 교체 이동 + meetup도 함께 전달
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingRoomScreen(
          party: _toParty(m),
          meetup: m, // ← 준비 취소 시 전역에서도 -1 가능
          isLeader: false,
        ),
      ),
    );
  }

  // 모임 인증하기 (기존 그대로)
  Future<void> _verifyMeetup() async {
    final reward = m.rewardPoint;
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MissionVerifyScreen(
          title: m.title,
          rewardPoint: reward,
        ),
      ),
    );
    if (done == true && mounted) {
      PointsState().add(reward);

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

  // ✅ 정원 찼을 때 채팅방으로 이동
  void _startChat() {
    final roomId = (m.id?.toString() ?? 'meetup-${m.hashCode}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          roomId: roomId,
          title: m.title,
          currentUserName: '나',
        ),
      ),
    );
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
                    Text(m.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_isFull ? '모집완료' : '모집중',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
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

          // ✅ 액션 버튼 (정원 여부에 따라 분기)
          if (!_isFull) ...[
            FilledButton(
              onPressed: _join,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: const Text('참가하기'),
            ),
            const SizedBox(height: 8),
          ] else ...[
            FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: const Text('모집완료'),
            ),
            const SizedBox(height: 8),
            // 정원이 꽉 찼으면 채팅 시작하기 노출
            FilledButton.tonal(
              onPressed: _startChat,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: const Text('채팅 시작하기'),
            ),
            const SizedBox(height: 8),
          ],

          // (항상 보이는) 모임 인증/돌아가기
          FilledButton.tonal(
            onPressed: _verifyMeetup,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('모임 인증하기'),
          ),

          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
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
