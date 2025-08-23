class UserProgress {
  static final UserProgress _i = UserProgress._internal();
  factory UserProgress() => _i;
  UserProgress._internal();

  int _completed = 0;
  int _points = 0;

  int get completed => _completed;
  int get points => _points;

  /// 미션 완료 처리 (포인트 지급)
  void completeMission(int rewardPoint) {
    _completed += 1;
    _points += rewardPoint;
  }
}
