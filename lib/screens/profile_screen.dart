import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 32, child: Text('사용자')),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('김사용자', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w800)),
                Text('@user123', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(children: const [
                  _Count('1.2K', '팔로워'), SizedBox(width: 16),
                  _Count('89', '팔로잉'),  SizedBox(width: 16),
                  _Count('42', '게시물'),
                ]),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          const Text('소개'),
          const SizedBox(height: 6),
          const Text('안녕하세요! 새로운 기술과 디자인에 관심이 많은 개발자입니다. 항상 배우고 성장하는 것을 즐깁니다.'),
          const SizedBox(height: 16),
          const Text('업적'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: const [
            _Badge('첫 게시물'), _Badge('인기 작성자'), _Badge('연속 방문', locked: true),
          ]),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final String value, label;
  const _Count(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) =>
      Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800)), Text(label)]);
}

class _Badge extends StatelessWidget {
  final String label;
  final bool locked;
  const _Badge(this.label, {this.locked = false, super.key});
  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(locked ? Icons.lock_outline : Icons.emoji_events_outlined, size: 18), label: Text(label));
}
