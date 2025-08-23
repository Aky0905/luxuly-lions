// lib/models/meetup.dart
class Meetup {
  final String id;
  final String title;
  final String description;
  final String location; // 예: '반포한강공원'
  final DateTime when;
  final int capacity;
  int joined;

  final int rewardPoint; // 인증 보상 (기본 200P)

  Meetup({
    String? id,                 // ← 선택값으로 변경
    required this.title,
    required this.description,
    required this.location,
    required this.when,
    required this.capacity,
    this.joined = 0,
    this.rewardPoint = 200,
  }) : id = id ?? _genId();     // ← 값 없으면 자동 생성
}

String _genId() {
  final now = DateTime.now().millisecondsSinceEpoch.toString();
  return 'mt-$now';
}
