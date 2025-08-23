import 'package:flutter/material.dart';
import '../models/coupon.dart';
import '../state/coupon_state.dart';
import 'mission_verify_screen.dart'; // ✅ 인증 화면

class MissionDetailScreen extends StatefulWidget {
  final String title;
  final String place;
  final String distance;
  final String timeLimit;
  final String point;
  /// "현재/최대" 형식 (예: "2/4")
  final String participants;

  const MissionDetailScreen({
    super.key,
    required this.title,
    required this.place,
    required this.distance,
    required this.timeLimit,
    required this.point,
    required this.participants,
  });

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  late int _now;
  late int _max;

  @override
  void initState() {
    super.initState();
    final parts = widget.participants.split('/');
    _now = int.tryParse(parts.first.trim()) ?? 0;
    _max = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
  }

  bool get _isFull => _max > 0 && _now >= _max;

  void _join() {
    if (_now < _max) {
      setState(() => _now++);
      if (_now >= _max) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정원이 모두 모였어요! 쿠폰을 받을 수 있어요.')),
        );
      }
    }
  }

  // ✅ 바코드용 코드/ID 생성해서 쿠폰 저장
  void _downloadCoupon() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch.toString();
    final code =
        'LM-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${ts.substring(ts.length - 6)}';

    final coupon = Coupon(
      id: 'coupon-$ts',
      title: '${widget.title} 할인쿠폰',
      description: '${widget.place}에서 사용할 수 있는 ${widget.point} 쿠폰',
      issuedAt: now,
      code: code,
    );

    CouponState().addCoupon(coupon);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('쿠폰이 내 쿠폰함에 저장되었습니다!')),
    );
  }

  Future<void> _goVerify() async {
    final reward =
        int.tryParse(widget.point.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            MissionVerifyScreen(title: widget.title, rewardPoint: reward),
      ),
    );
    if (done == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('미션 인증 완료! +${reward}P 적립')),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미션')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 제목/장소/난이도 배지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(widget.place),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE), // ✅ 연보라 톤 통일
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('쉬움',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 프로모 배너 + (조건) 쿠폰 다운로드 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('특별 할인 혜택',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('코엑스 아쿠아리움에서 20% 할인!'),
                const SizedBox(height: 12),
                if (_isFull)
                  FilledButton.icon(
                    onPressed: _downloadCoupon,
                    icon: const Icon(Icons.download),
                    label: const Text('할인쿠폰 다운로드'),
                  )
                else
                  Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 18),
                      SizedBox(width: 6),
                      Text('참가자가 모두 모이면 쿠폰이 활성화됩니다'),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 메트릭 4개
          Row(
            children: [
              _MetricBox(title: '거리', value: widget.distance),
              const SizedBox(width: 12),
              _MetricBox(title: '제한시간', value: widget.timeLimit),
              const SizedBox(width: 12),
              _MetricBox(title: '보상', value: widget.point),
              const SizedBox(width: 12),
              _MetricBox(title: '참가자', value: '$_now/$_max'),
            ],
          ),
          const SizedBox(height: 16),

          // 참가자 리스트(샘플)
          Text('현재 참가자 ($_now명)'),
          const SizedBox(height: 8),
          const ListTile(
              leading: CircleAvatar(child: Text('A')), title: Text('참가자 1')),
          const ListTile(
              leading: CircleAvatar(child: Text('B')), title: Text('참가자 2')),
          const SizedBox(height: 16),

          // 액션 버튼
          FilledButton(
            onPressed: _isFull ? null : _join,
            style:
            FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(_isFull ? '정원 마감' : '일행 모집 참가하기'),
          ),
          const SizedBox(height: 8),

          // 문구 통일: "미션 인증하기"
          FilledButton.tonal(
            onPressed: _goVerify,
            style:
            FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('미션 인증하기'),
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
