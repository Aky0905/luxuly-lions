import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../state/coupon_state.dart';
import '../models/coupon.dart';

class CouponDetailScreen extends StatefulWidget {
  final String couponId;
  const CouponDetailScreen({super.key, required this.couponId});

  @override
  State<CouponDetailScreen> createState() => _CouponDetailScreenState();
}

class _CouponDetailScreenState extends State<CouponDetailScreen> {
  Coupon? get coupon => CouponState().findById(widget.couponId);

  @override
  Widget build(BuildContext context) {
    final c = coupon;
    if (c == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('쿠폰 상세')),
        body: const Center(child: Text('쿠폰을 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 제목/설명
          Text(c.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(c.description),
          const SizedBox(height: 16),

          // 상태 배지
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.isUsed ? Colors.red.withOpacity(.12) : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(c.isUsed ? '사용완료' : '미사용',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),

          // 바코드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: c.code, // ✅ 바코드에 들어갈 코드
                    width: double.infinity,
                    height: 120,
                    drawText: true,
                  ),
                  const SizedBox(height: 8),
                  Text('코드: ${c.code}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text('지급일: ${_fmt(c.issuedAt)}', style: Theme.of(context).textTheme.bodySmall),
          if (c.usedAt != null)
            Text('사용일: ${_fmt(c.usedAt!)}', style: Theme.of(context).textTheme.bodySmall),

          const SizedBox(height: 24),

          // 사용하기 버튼
          FilledButton(
            onPressed: c.isUsed
                ? null
                : () {
              final ok = CouponState().markUsed(c.id);
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('사용 완료 처리되었습니다.')),
                );
                setState(() {});
              }
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(c.isUsed ? '이미 사용됨' : '사용 완료 처리'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.year}.${d.month}.${d.day} ${d.hour}:$mm';
  }
}
