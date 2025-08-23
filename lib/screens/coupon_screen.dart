import 'package:flutter/material.dart';
import '../state/coupon_state.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coupons = CouponState().coupons;

    return Scaffold(
      appBar: AppBar(title: const Text('내 쿠폰함')),
      body: coupons.isEmpty
          ? const Center(child: Text('저장된 쿠폰이 없습니다.'))
          : ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, i) {
          final c = coupons[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: Text(c.title),
              subtitle: Text('${c.description}\n발급일: ${c.issuedAt.toLocal()}'),
            ),
          );
        },
      ),
    );
  }
}
