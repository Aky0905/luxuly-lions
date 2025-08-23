import 'package:flutter/material.dart';
import 'shell.dart'; // 앱 시작 화면(AppShell)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '동네 친구',
      theme: ThemeData(
        useMaterial3: true,

        // 🎨 메인 팔레트 (하늘색 계열)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.light,
        ),

        // 배경 톤 살짝 밝게
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),

        // ✅ 폰트 (pubspec.yaml에 Pretendard 등록되어 있어야 함)
        fontFamily: 'Pretendard',

        // ✅ AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Colors.black54),
        ),

        // ✅ 카드
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          color: Colors.white,
        ),

        // ✅ 버튼들 둥글게
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // ✅ Chip (뱃지 느낌)
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey.shade200,
          selectedColor: const Color(0xFF4FC3F7).withOpacity(0.2),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),

        // ✅ FAB (가운데 상점 버튼)
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF74D4FF),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ✅ 하단 바(노치 있는 BottomAppBar용)
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.white,
          elevation: 5,
        ),
      ),
      home: const AppShell(),
    );
  }
}
