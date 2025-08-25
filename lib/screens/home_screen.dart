import 'package:flutter/material.dart';
import 'mission_screen.dart'; // 지역 미션으로 이동
import 'location_setting_screen.dart'; // 위치 설정
import '../state/meetup_state.dart'; // 모임 프리뷰 데이터
import 'meetups_screen.dart'; // 동네 팟 목록/생성
import 'meetup_detail_screen.dart'; // 동네 팟 상세

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentArea = '강남구 · 서울특별시';
  String _query = ''; // 🔎 검색어

  @override
  Widget build(BuildContext context) {
    final all = MeetupState().meetups;

    // 홈에서는 검색어로 필터해 최대 5개만 프리뷰
    final meetups = all
        .where((m) {
          if (_query.trim().isEmpty) return true;
          final q = _query.toLowerCase();
          return m.title.toLowerCase().contains(q) ||
              m.description.toLowerCase().contains(q) ||
              m.location.toLowerCase().contains(q);
        })
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 위치 + 변경
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _currentArea,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                        builder: (_) => const LocationSettingScreen()),
                  );
                  if (result != null && result.isNotEmpty) {
                    setState(() => _currentArea = result);
                  }
                },
                icon: const Icon(Icons.near_me_outlined, size: 18),
                label: const Text('위치 변경'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 히어로 카피
          Text(
            '${_currentArea.split(' · ').first}에서 모험을 시작하세요!',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          // 🔎 홈 검색창
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: '동네 팟 검색 (예: 런닝, 독서, 등산...)',
            ),
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),

          // 지역 미션 이동 카드
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('지역 미션 보러가기'),
              subtitle: const Text('근처에서 할 수 있는 공식 미션을 확인하세요'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MissionScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 섹션 헤더
          Row(
            children: [
              Text(
                '동네 팟 찾기',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              if (_query.isNotEmpty)
                Text(
                  '검색 결과 ${meetups.length}개',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MeetupsScreen(currentArea: _currentArea),
                    ),
                  );
                },
                child: const Text('더 보기'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 프리뷰 리스트
          if (meetups.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _query.isEmpty
                      ? '근처 모임이 없어요. 첫 모임을 만들어보세요!'
                      : '\'$_query\' 관련 모임이 없어요. 다른 키워드로 찾아보세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...meetups.map(
              (m) => Card(
                child: ListTile(
                  title: Text(
                    m.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${m.location} • ${_fmt(m.when)}\n${m.description}',
                  ),
                  isThreeLine: true,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${m.joined}/${m.capacity}'),
                  ),
                  // 프리뷰 카드 탭 → 상세로
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MeetupDetailScreen(
                          meetup: m,
                          currentArea: _currentArea, // 상세에서 대략 거리 표시용
                        ),
                      ),
                    );
                    setState(() {}); // 상세에서 변경된 인원 수 반영
                  },
                ),
              ),
            ),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeetupsScreen(currentArea: _currentArea),
                ),
              );
            },
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('모임 만들기/찾기'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.month}/${d.day} ${d.hour}:$mm';
  }
}
