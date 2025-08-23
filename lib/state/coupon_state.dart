import '../models/coupon.dart';

class CouponState {
  static final CouponState _instance = CouponState._internal();
  factory CouponState() => _instance;
  CouponState._internal();

  final List<Coupon> _coupons = [];
  List<Coupon> get coupons => List.unmodifiable(_coupons);

  void addCoupon(Coupon coupon) {
    _coupons.insert(0, coupon);
  }

  Coupon? findById(String id) {
    try {
      return _coupons.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool markUsed(String id) {
    final c = findById(id);
    if (c == null) return false;
    if (c.isUsed) return false;
    c.isUsed = true;
    c.usedAt = DateTime.now();
    return true;
  }
}
