import '../models/meetup.dart';

class MeetupState {
  static final MeetupState _i = MeetupState._internal();
  factory MeetupState() => _i;
  MeetupState._internal() {
    // 데모용 초기 데이터
    if (_meetups.isEmpty) {
      _meetups.addAll([
        Meetup(
          title: '오늘 저녁 러닝 5km',
          description: '한강 러닝 가실 분! 초보 환영',
          when: DateTime.now().add(const Duration(hours: 3)),
          location: '잠원한강공원',
          capacity: 6,
          joined: 2,
        ),
        Meetup(
          title: '북스루 독서모임',
          description: '이번 주 책: 작은 습관의 힘',
          when: DateTime.now().add(const Duration(days: 1, hours: 2)),
          location: '강남역 근처 카페',
          capacity: 8,
          joined: 5,
        ),
        Meetup(
          title: '주말 등산 소모임',
          description: '북한산 초급 코스',
          when: DateTime.now().add(const Duration(days: 2)),
          location: '불광역 2번 출구',
          capacity: 10,
          joined: 9,
        ),
      ]);
    }
  }

  final List<Meetup> _meetups = [];
  List<Meetup> get meetups => List.unmodifiable(_meetups);

  void add(Meetup m) => _meetups.insert(0, m);

  void join(Meetup m) {
    if (m.joined < m.capacity) {
      m.joined++;
    }
  }

  // ⬇️ 추가: 참가 취소 메서드
  void leave(Meetup m) {
    if (m.joined > 0) {
      m.joined--;
    }
  }
}
