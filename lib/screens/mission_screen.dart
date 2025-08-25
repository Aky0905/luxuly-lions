import 'package:flutter/material.dart';
import '../state/user_progress.dart';
import 'mission_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // ✅ 추가: Provider
import '../state/area_state.dart'; // ✅ 추가: AreaState
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});
  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = UserProgress();

    // ✅ 현재 지역을 Provider에서 읽음
    final currentArea = context.watch<AreaState>().currentArea;

    return Scaffold(
      appBar: AppBar(title: const Text('미션')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ 상단 요약 카드들
          Row(
            children: [
              _StatCard(
                  label: '완료한 미션',
                  value: '${progress.completed}개',
                  icon: Icons.emoji_events_outlined),
              const SizedBox(width: 12),
              _StatCard(
                  label: '획득 포인트',
                  value: '${progress.points}P',
                  icon: Icons.star_border),
            ],
          ),
          const SizedBox(height: 16),

          // 진행중인 미션 (AI 추천)
          FutureBuilder<List<Map<String, String>>>(
            future: fetchAIMissions(currentArea),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final missions = snapshot.data!;
              return Column(
                children: List.generate(
                    missions.length,
                    (i) => Column(
                          children: [
                            _MissionTile(
                              title: missions[i]['title']!,
                              place: missions[i]['place']!,
                              difficulty: '보통',
                              point: '500P',
                            ),
                            const SizedBox(height: 8),
                            // 필요하다면 기존 데모 미션을 추가로 넣을 수 있습니다.
                          ],
                        )),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final String title, place, difficulty, point;
  final bool done;
  const _MissionTile({
    required this.title,
    required this.place,
    required this.difficulty,
    required this.point,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('$place • 난이도 $difficulty • 보상 $point'),
          trailing: FilledButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MissionDetailScreen(
                  title: title,
                  place: place.split(' · ').first,
                  distance:
                      place.contains('·') ? place.split('·').last.trim() : '',
                  timeLimit: difficulty == '보통' ? '3시간' : '2시간',
                  point: point,
                  participants: done ? '6/6' : '3/6',
                ),
              ));
            },
            child: const Text('자세히'),
          ),
        ),
      ),
    );
  }
}

// ...existing code...

Future<List<Map<String, String>>> fetchAIMissions(String currentArea) async {
  final prompt = '''
저는 현재 $currentArea에 있어요.
주변에 유명한 카페, 문화유산, 랜드마크, 박물관, 미술관 등 두 곳을 추천해 주세요.
답변은 반드시 각 줄마다 "장소명에서 할일하기!" 형식으로 2개 작성해 주세요.
예시:
성수동 대림창고 갤러리에서 커피마시기!
남산타워에서 야경보기!
장소명은 실제 지역 내에 있는 곳으로, 할일은 그 장소에서 할 수 있는 활동으로 작성해 주세요.
''';

  final apiKey = dotenv.env['OPENAI_API_KEY'];

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 100,
      "temperature": 0.8,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final aiResponse = data['choices'][0]['message']['content'].trim();

    // 줄 단위로 분리해서 2개만 추출
    final lines = aiResponse
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(2)
        .toList();

    final random = Random();
    return List.generate(lines.length, (i) {
      final placeName = lines[i].split('에서').first.trim();
      final distance = (random.nextDouble() * 2 + 1).toStringAsFixed(1);
      return {
        'title': lines[i],
        'place': '$placeName · ${distance}km',
      };
    });
  } else {
    // 실패 시 예시 데이터 2개 반환
    return [
      {
        'title': '성수동 대림창고 갤러리에서 커피마시기',
        'place': '성수동 대림창고 갤러리 · 2.1km',
      },
      {
        'title': '남산타워에서 야경보기',
        'place': '남산타워 · 2.8km',
      },
    ];
  }
}
