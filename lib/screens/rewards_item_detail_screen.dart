import 'package:flutter/material.dart';
import '../state/points_state.dart';
import '../state/coupon_state.dart';
import '../models/coupon.dart';

class RewardsItemDetailScreen extends StatelessWidget {
  final String id;
  final String title;
  final String partner;
  final String category; // 카페/식당/편의점/문화/기타
  final int cost;
  final String area;     // 예: 강남구
  final String desc;
  final String emoji;
  final List<String> tags;

  const RewardsItemDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.partner,
    required this.category,
    required this.cost,
    required this.area,
    required this.desc,
    required this.emoji,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final balance = PointsState().balance;
    final canBuy = balance >= cost;

    return Scaffold(
      appBar: AppBar(title: const Text('상세 보기')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 썸네일
          Container(
            height: 140,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 16),

          // 제목/파트너/카테고리
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('$partner • $category', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$cost P'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 지역/태그
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 6),
              Text(area.isEmpty ? '전국 사용 가능' : area),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: -6,
              children: tags
                  .map((t) => Chip(
                label: Text(t),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(vertical: -4),
              ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 16),
          Text('상품 설명', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(desc),

          const SizedBox(height: 20),
          // 내 포인트
          Row(
            children: [
              const Icon(Icons.savings_outlined, size: 18),
              const SizedBox(width: 6),
              Text('내 포인트: $balance P'),
              const Spacer(),
              if (!canBuy)
                Text('부족 ${cost - balance}P',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.red)),
            ],
          ),

          const SizedBox(height: 16),
          // 구매 버튼
          FilledButton(
            onPressed: canBuy
                ? () {
              final ok = PointsState().spend(cost);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('포인트가 부족합니다.')),
                );
                return;
              }

              final now = DateTime.now().millisecondsSinceEpoch;
              final coupon = Coupon(
                id: 'shop-$id-$now',
                title: title,
                description: '$partner에서 사용 가능한 쿠폰',
                issuedAt: DateTime.now(),
                code: _genCode(now),
              );
              CouponState().addCoupon(coupon);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('구매 완료! 쿠폰함에 저장되었습니다.')),
              );
              Navigator.pop(context);
            }
                : null,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(canBuy ? '구매하기' : '포인트 부족'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // 간단한 쿠폰코드 생성기 (예: CPN-9X7F4A2Q)
  String _genCode(int seed) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final buf = StringBuffer('CPN-');
    var h = seed ^ 0x5f3759df;
    for (int i = 0; i < 8; i++) {
      h = (h * 1103515245 + 12345) & 0x7fffffff;
      buf.write(alphabet[h % alphabet.length]);
    }
    return buf.toString();
  }
}
