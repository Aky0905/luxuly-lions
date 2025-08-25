// lib/state/xp_state.dart
import 'points_state.dart';

class XpState {
  static final XpState _i = XpState._internal();
  factory XpState() => _i;
  XpState._internal();

  // ===== 설정값(자유 조정) =====
  static const int xpMissionVerify = 50; // 미션 인증
  static const int xpMeetupVerify = 50; // 모임 인증
  static const int xpCheckInBase = 10; // 출석 기본
  static const int xpCheckIn3 = 30; // 3일 연속 보너스
  static const int xpCheckIn7 = 70; // 7일 연속 보너스
  static const int xpFirstBonus = 100; // 첫 참가 보너스
  static const int xpStepForPts = 50; // XP 50 단위마다
  static const int ptsPerXpStep = 300; // → 300P 지급

  int _xp = 0;
  int get xp => _xp;

  // 이미 지급된 "50XP 스텝" 수 (예: 0~49=0, 50~99=1, 100~149=2 …)
  int _awardedSteps = 0;

  // 레벨 계산: 필요 XP = 100 * n^2
  int get level {
    int n = 1;
    while (_xp >= _needFor(n + 1)) {
      n++;
    }
    return n;
  }

  int _needFor(int n) => 100 * n * n;
  int get currentLevelNeed => _needFor(level);
  int get nextLevelNeed => _needFor(level + 1);

  double get progress {
    final denom = (nextLevelNeed - currentLevelNeed);
    if (denom <= 0) return 1;
    final v = (_xp - currentLevelNeed) / denom;
    return v.clamp(0.0, 1.0);
  }

  // 출석 체크 상태
  DateTime? lastCheckIn; // 마지막 출석 날짜
  int streak = 0; // 연속 출석 일수

  // 첫 참가 보너스 중복 방지
  final Set<String> _firstMission = {}; // missionId
  final Set<String> _firstMeetup = {}; // meetupId

  // 등급 이름
  String get grade {
    if (level < 5) return '새싹 탐험가 🌱';
    if (level < 10) return '거리의 방랑자 🥾';
    if (level < 20) return '도시 정복자 🏙️';
    if (level < 30) return '랜드마스터 🗼';
    return '레전드 탐험가 🏆';
  }

  /// 내부 공용: XP 적립 + 50XP 스텝 보너스 포인트 자동 지급
  int _addXp(int amount) {
    final beforeLevel = level;
    final beforeSteps = _xp ~/ xpStepForPts;

    _xp += amount;

    final afterSteps = _xp ~/ xpStepForPts;
    final newlyCompletedSteps = (afterSteps - beforeSteps) - _awardedSteps;
    // 위 식은 add 연속 호출 시 중복 방지용. 더 단순히: (afterSteps - _awardedSteps) 도 OK.
    final stepsToGrant = (afterSteps - _awardedSteps);
    if (stepsToGrant > 0) {
      PointsState().add(ptsPerXpStep * stepsToGrant);
      _awardedSteps += stepsToGrant;
    }

    final afterLevel = level;
    return afterLevel - beforeLevel; // 레벨업 수
  }

  /// 출석 체크: 오늘 중복 방지 + 기본/연속 보너스 XP
  int checkIn() {
    final today = DateTime.now();
    if (lastCheckIn != null && _isSameDate(lastCheckIn!, today)) {
      return 0; // 이미 오늘 함
    }

    final wasConsecutive = lastCheckIn != null &&
        today
                .difference(DateTime(
                    lastCheckIn!.year, lastCheckIn!.month, lastCheckIn!.day))
                .inDays ==
            1;

    if (wasConsecutive) {
      streak++;
    } else {
      streak = 1;
    }
    lastCheckIn = today;

    int bonus = xpCheckInBase;
    if (streak == 3) bonus += xpCheckIn3;
    if (streak == 7) bonus += xpCheckIn7;

    _addXp(bonus);
    // 포인트도 동시에 주고 싶다면 여기서 PointsState().add(...) 추가 가능
    return bonus;
  }

  /// 미션 인증 성공 시
  int onMissionVerified({required String missionId}) {
    int gained = xpMissionVerify;
    // 첫 참가 보너스
    if (_firstMission.add(missionId)) {
      gained += xpFirstBonus;
    }
    return _addXp(gained);
  }

  /// 모임 인증 성공 시
  int onMeetupVerified({required String meetupId}) {
    int gained = xpMeetupVerify;
    // 첫 참가 보너스
    if (_firstMeetup.add(meetupId)) {
      gained += xpFirstBonus;
    }
    return _addXp(gained);
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
