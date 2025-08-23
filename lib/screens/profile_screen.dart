import 'package:flutter/material.dart';
import '../state/coupon_state.dart';
import '../models/coupon.dart';
import 'coupon_detail_screen.dart';

// ✅ XP/레벨 상태
import '../state/xp_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final xp = XpState(); // 싱글턴

  @override
  Widget build(BuildContext context) {
    final coupons = CouponState().coupons;

    // 진행도 계산(안전하게 0~1 사이로 클램프)
    final curr = xp.currentLevelNeed;
    final next = xp.nextLevelNeed;
    final denom = (next - curr).clamp(1, 1 << 30); // 0분모 방지
    final progress = ((xp.xp - curr) / denom).clamp(0.0, 1.0);
    final toNext = (next - xp.xp).clamp(0, 1 << 31);

    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 사용자 + 레벨/등급 박스
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 32, child: Text('사용자')),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '김사용자',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text('@user123',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),

                    // ✅ 레벨/등급/경험치 진행도
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('Lv.${xp.level}',
                              style:
                              const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Text(xp.grade),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Tooltip(
                      message: '다음 레벨까지 $toNext XP',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('총 ${xp.xp} XP • 다음 레벨까지 $toNext XP'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ 출석 체크 (연속 참여 보너스)
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    final bonus = xp.checkIn();
                    setState(() {}); // 레벨/바 갱신
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '출석체크 완료! 연속 ${xp.streak}일'
                              '${bonus > 0 ? " (보너스 +$bonus XP)" : ""}',
                        ),
                      ),
                    );
                  },
                  child: const Text('오늘 출석체크 하기'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 소개
          const Text('소개'),
          const SizedBox(height: 6),
          const Text(
            '안녕하세요! 새로운 기술과 디자인에 관심이 많은 개발자입니다. 항상 배우고 성장하는 것을 즐깁니다.',
          ),
          const SizedBox(height: 16),

          // 업적 (예시)
          const Text('업적'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              _Badge('첫 게시물'),
              _Badge('인기 작성자'),
              _Badge('연속 방문', locked: true),
            ],
          ),

          const SizedBox(height: 24),

          // ✅ 쿠폰함
          Row(
            children: [
              Text(
                '내 쿠폰함',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text('${coupons.length}개',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),

          if (coupons.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('아직 받은 쿠폰이 없습니다. 미션/모임 인증으로 혜택을 받아보세요!'),
            )
          else
            ...coupons.map((c) => _CouponTile(
              c: c,
              onChanged: () => setState(() {}), // 상세 다녀온 뒤 새로고침
            )),
        ],
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  final Coupon c;
  final VoidCallback onChanged;
  const _CouponTile({required this.c, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.isUsed ? Colors.red.withOpacity(.12) : const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(c.isUsed ? '사용완료' : '미사용'),
    );

    return Card(
      child: ListTile(
        leading: Icon(
          c.isUsed ? Icons.inventory_2_outlined : Icons.card_giftcard_outlined,
        ),
        title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${c.description}\n지급일: ${_fmt(c.issuedAt)}'
              '${c.isUsed && c.usedAt != null ? '\n사용일: ${_fmt(c.usedAt!)}' : ''}',
        ),
        isThreeLine: true,
        trailing: statusChip,
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CouponDetailScreen(couponId: c.id),
            ),
          );
          onChanged(); // 상세에서 사용 처리 후 목록 반영
        },
      ),
    );
  }

  String _fmt(DateTime d) {
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.year}.${d.month}.${d.day} ${d.hour}:$mm';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool locked;
  const _Badge(this.label, {this.locked = false, super.key});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(
      locked ? Icons.lock_outline : Icons.emoji_events_outlined,
      size: 18,
    ),
    label: Text(label),
  );
}
