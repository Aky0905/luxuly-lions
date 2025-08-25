import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ 로그아웃용
import '../ui/login_page.dart'; // ✅ 로그인 화면으로 이동

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('설정'), centerTitle: true),
      body: ListView(
        children: [
          const _Section(title: '알림', children: [
            _SwitchTile('푸시 알림'),
            _SwitchTile('이메일 알림'),
          ]),
          _Section(title: '모양', children: [
            _SwitchTile('다크 모드'),
          ]),
          const _Section(title: '계정', children: [
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('프로필 수정'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('개인정보 보호'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('도움말'),
              trailing: Icon(Icons.chevron_right),
            ),
          ]),
          // ✅ 활성화된 로그아웃 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () async {
                // Firebase 세션 정리
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (_) {}

                if (!context.mounted) return;
                // 스택 비우고 로그인 화면으로
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: th.colorScheme.primary,
                foregroundColor: th.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('로그아웃'),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7FAFF),
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
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.w800),
            ),
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
  Widget build(BuildContext context) => SwitchListTile(
        title: Text(widget.label),
        value: v,
        onChanged: (x) => setState(() => v = x),
      );
}
