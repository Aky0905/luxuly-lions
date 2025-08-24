import 'package:flutter/material.dart';

class ChatMessage {
  final String user;
  final String text;
  final DateTime at;
  ChatMessage({required this.user, required this.text, DateTime? at})
      : at = at ?? DateTime.now();
}

/// 데모용 인메모리 저장소 (앱 재실행 시 초기화됨)
class InMemoryChatStore {
  static final InMemoryChatStore _i = InMemoryChatStore._();
  factory InMemoryChatStore() => _i;
  InMemoryChatStore._();

  final Map<String, List<ChatMessage>> _byRoom = {};

  List<ChatMessage> messages(String roomId) =>
      _byRoom.putIfAbsent(roomId, () => []);

  void send(String roomId, ChatMessage m) {
    messages(roomId).add(m);
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String title;
  final String currentUserName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.title,
    this.currentUserName = '나',
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final _store = InMemoryChatStore();
  final _scrollCtrl = ScrollController();

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    _store.send(
      widget.roomId,
      ChatMessage(user: widget.currentUserName, text: txt),
    );
    _controller.clear();
    setState(() {});
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _store.messages(widget.roomId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                final mine = m.user == widget.currentUserName;
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mine
                          ? const Color(0xFF1976D2).withOpacity(0.12)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: mine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.user,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(m.text),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _send,
                  child: const Icon(Icons.send),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
