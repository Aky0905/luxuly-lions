import '../models/coupon.dart';

class CouponState {
  static final CouponState _instance = CouponState._internal();
  factory CouponState() => _instance;
  CouponState._internal();

  final List<Coupon> _coupons = [];
  List<Coupon> get coupons => List.unmodifiable(_coupons);

  void addCoupon(Coupon coupon) {
    _coupons.add(coupon);
  }
}
