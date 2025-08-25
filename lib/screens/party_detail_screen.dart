//party_detail_screen
import 'package:flutter/material.dart';
import '../models/party.dart';
import 'waiting_room_screen.dart';

class PartyDetailScreen extends StatefulWidget {
  final Party party;
  const PartyDetailScreen({super.key, required this.party});

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  bool _joining = false;

  Future<void> _joinAndGoWaiting() async {
    if (_joining) return;
    setState(() => _joining = true);

    // 1) 정원 체크
    if (widget.party.joined >= widget.party.capacity) {
      setState(() => _joining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정원이 가득 찼습니다.')),
      );
      return;
    }

    // 2) 참가자 추가 (로컬)
    widget.party.joined += 1;
    widget.party.people.add(Participant(name: '나', level: 15, ready: false));

    // ※ Firestore 사용 시:
    // await FirebaseFirestore.instance.collection('parties')
    //   .doc(widget.party.id).update({
    //     'joined': FieldValue.increment(1),
    //     'participants': FieldValue.arrayUnion([{'name':'나','level':15,'ready':false}]),
    //   });

    // 3) 대기실로 pushReplacement (뒤로가기시 상세 안보이게)
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingRoomScreen(party: widget.party, isLeader: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.party;
    return Scaffold(
      appBar: AppBar(title: const Text('동네 팟 상세')),
      body: Column(
        children: [
          // ... 제목/장소/일시/보상/참가자 UI ...
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _joining ? null : _joinAndGoWaiting,
                child: Text(_joining ? '참가 중...' : '참가하기'),
              ),
            ),
          ),
          // '모임 인증하기' / '돌아가기' 버튼들은 그대로
        ],
      ),
    );
  }
}
