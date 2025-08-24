import 'package:flutter/material.dart';
import 'package:characters/characters.dart';

import '../models/party.dart';
import '../models/meetup.dart'; // 원본 Meetup 인스턴스 직접 수정용
import 'chat_room_screen.dart'; // <-- 채팅 화면

class WaitingRoomScreen extends StatefulWidget {
  final Party party;
  final Meetup? meetup; // 원본 Meetup (옵션)
  final bool isLeader; // 방장 여부

  const WaitingRoomScreen({
    super.key,
    required this.party,
    this.meetup,
    this.isLeader = false,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  void _toggleReady(int idx) {
    setState(() {
      widget.party.people[idx].ready = !widget.party.people[idx].ready;
    });
  }

  /// 준비 취소: 인원 -1, '나' 제거, 전달받은 meetup 인스턴스도 -1
  void _cancelJoin() {
    setState(() {
      // 1) 로컬 Party에서 '나' 제거
      final idx = widget.party.people.indexWhere((u) => u.name == '나');
      if (idx != -1) {
        widget.party.people.removeAt(idx);
      }
      // 2) 파티 인원 감소
      if (widget.party.joined > 0) {
        widget.party.joined -= 1;
      }
      // 3) 전역 meetup 인스턴스도 같이 감소 (같은 객체를 전달받았다는 가정)
      if (widget.meetup != null && widget.meetup!.joined > 0) {
        widget.meetup!.joined -= 1;
      }
    });

    // 4) 화면 닫기
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.party;
    final readyCount = p.people.where((e) => e.ready).length;
    final isFull = p.joined >= p.capacity;

    return Scaffold(
      appBar: AppBar(title: const Text('대기실')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 상단 카드: 모집 현황
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(p.place),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('참가자 모집'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${p.joined}/${p.capacity}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: p.joined / p.capacity,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text(isFull ? '모집 완료!' : '모집 중')),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 참가자 목록
          Text('👥 참가자 목록', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(p.people.length, (i) {
            final user = p.people[i];
            final me = user.name == '나';
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(user.name.characters.first)),
                title: Row(
                  children: [
                    Text(user.name),
                    if (me) const SizedBox(width: 6),
                    if (me) const Icon(Icons.emoji_events, size: 16),
                  ],
                ),
                subtitle: Text('Lv.${user.level}'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.ready
                        ? Colors.black
                        : Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    user.ready ? '준비완료' : '대기중',
                    style: TextStyle(color: user.ready ? Colors.white : null),
                  ),
                ),
                onTap: me ? () => _toggleReady(i) : null,
              ),
            );
          }),

          const SizedBox(height: 16),

          // 미션 정보 (예시)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.timer_outlined),
                        SizedBox(height: 8),
                        Text('제한시간'),
                        SizedBox(height: 4),
                        Text('3시간',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.groups_outlined),
                        const SizedBox(height: 8),
                        const Text('최대인원'),
                        const SizedBox(height: 4),
                        Text('${p.capacity}명',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 하단 액션들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelJoin, // 준비 취소 → 실제 감소
                  child: const Text('준비 취소'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ 채팅 화면으로 이동 연결 (디버그 로그 포함)
          OutlinedButton.icon(
            onPressed: () {
              final roomId = (widget.meetup?.id?.toString() ?? widget.party.id);
              debugPrint('[WaitingRoom] 채팅하기 탭 roomId=$roomId');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    roomId: roomId,
                    title: widget.party.title,
                    currentUserName: '나',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('채팅하기'),
          ),

          const SizedBox(height: 8),
          FilledButton(
            onPressed: (widget.isLeader && readyCount == p.capacity)
                ? () {
                    // 모든 인원 준비완료 → 미션 시작 로직
                  }
                : null,
            child: const Text('미션 시작하기'),
          ),
        ],
      ),
    );
  }
}
