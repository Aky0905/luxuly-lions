import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shell.dart'; // ✅ 카카오 버튼 누르면 탭 쉘로 이동

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '랜드마크 익스플로러',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111827),
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: GoogleFonts.notoSansKrTextTheme(base.textTheme)
            .apply(bodyColor: const Color(0xFF111827)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        // ✅ Flutter 3.22+ : CardThemeData 사용
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _brandYellow = Color(0xFFFFD400); // 카카오 느낌 포인트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인'), actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.notifications_outlined),
        )
      ]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFF111827),
            child: Icon(Icons.place, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            '랜드마크 익스플로러',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            '친구들과 함께 서울을 탐험하고\n새로운 추억을 만들어보세요!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 기능 소개 카드 3개
          const _LoginTile(
            icon: Icons.map_outlined,
            title: '랜드마크 탐험',
            subtitle: '서울의 숨겨진 명소들을 발견해보세요',
          ),
          const SizedBox(height: 12),
          const _LoginTile(
            icon: Icons.group_outlined,
            title: '함께하는 모험',
            subtitle: '새로운 사람들과 함께 미션을 완료해요',
          ),
          const SizedBox(height: 12),
          const _LoginTile(
            icon: Icons.military_tech_outlined,
            title: '보상과 성취',
            subtitle: '미션 완료 후 포인트와 배지를 획득하세요',
          ),
          const SizedBox(height: 24),

          // 로그인 버튼들
          ElevatedButton.icon(
            onPressed: () {
              // TODO: 구글 로그인 연결 지점
            },
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Google로 시작하기'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ 카카오 버튼 → 탭 있는 메인(AppShell)으로 전환
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AppShell()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandYellow,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('카카오로 시작하기'),
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {
              // TODO: 이메일 로그인 이동 지점
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('이메일로 로그인'),
          ),
        ],
      ),
    );
  }
}

class _LoginTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LoginTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF7F7F9),
          child: Icon(Icons.place, color: Color(0xFF111827)), // 아이콘 색 통일
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
