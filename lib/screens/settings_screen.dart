import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: const [
          _Section(title: '알림', children: [
            _SwitchTile('푸시 알림'),
            _SwitchTile('이메일 알림'),
          ]),
          _Section(title: '모양', children: [
            _SwitchTile('다크 모드'),
          ]),
          _Section(title: '계정', children: [
            ListTile(leading: Icon(Icons.person_outline), title: Text('프로필 수정'), trailing: Icon(Icons.chevron_right)),
            ListTile(leading: Icon(Icons.shield_outlined), title: Text('개인정보 보호'), trailing: Icon(Icons.chevron_right)),
            ListTile(leading: Icon(Icons.help_outline), title: Text('도움말'), trailing: Icon(Icons.chevron_right)),
          ]),
          Padding(padding: EdgeInsets.all(16), child: FilledButton.tonal(onPressed: null, child: Text('로그아웃'))),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children, super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800)),
      ),
      ...children
    ],
  );
}

class _SwitchTile extends StatefulWidget {
  final String label;
  const _SwitchTile(this.label, {super.key});
  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}
class _SwitchTileState extends State<_SwitchTile> {
  bool v = false;
  @override
  Widget build(BuildContext context) =>
      SwitchListTile(title: Text(widget.label), value: v, onChanged: (x) => setState(() => v = x));
}
