import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ 메일/오류 한국어 설정용
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ 한국어 로컬라이제이션
import 'firebase_options.dart';
import 'shell.dart';
import 'ui/login_page.dart';
import 'ui/signup_step1_page.dart';
import 'ui/email_login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ✅ Firebase 인증 이메일/오류 메시지 한국어
  FirebaseAuth.instance.setLanguageCode('ko');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('준비중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '동네 친구',

      // ✅ 한국어 기본, 영어도 지원
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        fontFamily: 'Pretendard',

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

        // ⬇️ CardThemeData → CardTheme
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          color: Colors.white,
        ),

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

        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey.shade200,
          selectedColor: const Color(0xFF4FC3F7).withOpacity(0.2),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF74D4FF),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ⬇️ BottomAppBarThemeData → BottomAppBarTheme
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.white,
          elevation: 5,
        ),
      ),
      home: Builder(
        builder: (context) => LoginPage(
          onGoogleSignIn: () => _comingSoon(context), // 비활성
          onKakaoSignIn: () => _comingSoon(context), // 비활성
          onEmailLogin: () {
            // ✅ 로그인(이메일/비밀번호) 화면으로 이동
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmailLoginPage()),
            );
          },
          onSignUp: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SignupStep1Page(hideEmail: false),
              ),
            );
          },
        ),
      ),
    );
  }
}
