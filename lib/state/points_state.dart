// lib/state/points_state.dart
class PointsState {
  static final PointsState _i = PointsState._internal();
  factory PointsState() => _i;
  PointsState._internal();

  int _points = 0;
  int get balance => _points;

  /// 포인트 적립
  void add(int amount) {
    if (amount <= 0) return;
    _points += amount;
  }

  /// 포인트 사용 (성공=true)
  bool spend(int amount) {
    if (amount <= 0) return false;
    if (_points < amount) return false;
    _points -= amount;
    return true;
  }

  /// 충분한지
  bool canAfford(int amount) => _points >= amount;
}
