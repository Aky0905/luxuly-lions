import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          TextField(decoration: InputDecoration(hintText: '검색어를 입력하세요...')),
          SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            _Keyword('모바일 앱 개발'), _Keyword('React Native'), _Keyword('UI/UX 디자인'), _Keyword('픽셀 2'), _Keyword('안드로이드'),
          ]),
          SizedBox(height: 12),
          _Recent('사용자 인터페이스'),
          _Recent('모바일 최적화'),
          _Recent('터치 제스처'),
        ],
      ),
    );
  }
}

class _Keyword extends StatelessWidget {
  final String label;
  const _Keyword(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}

class _Recent extends StatelessWidget {
  final String label;
  const _Recent(this.label, {super.key});
  @override
  Widget build(BuildContext context) => ListTile(leading: const Icon(Icons.history), title: Text(label));
}
