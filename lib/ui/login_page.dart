import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    this.onGoogleSignIn,
    this.onKakaoSignIn,
    this.onEmailLogin,
    this.onSignUp,
  });

  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onKakaoSignIn;
  final VoidCallback? onEmailLogin;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ 화면이 낮으면(예: 720 미만) 컴팩트 모드로 축소
    final height = MediaQuery.of(context).size.height;
    final compact = height < 720;

    // 사이즈 프리셋
    final avatarRadius = compact ? 28.0 : 36.0;
    final headerIconSize = compact ? 26.0 : 34.0;
    final headerGap = compact ? 8.0 : 12.0;
    final headerBottomGap = compact ? 14.0 : 20.0;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: compact ? 16 : theme.textTheme.titleMedium?.fontSize,
    );
    final descStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: compact ? 13 : null,
      color: theme.colorScheme.onSurface.withOpacity(.7),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('로그인'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {},
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compact ? 12 : 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== 헤더(조금 작게) =====
                  Column(
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : const Color(0xFFE7F5FF),
                        child: Icon(
                          Icons.place_outlined,
                          size: headerIconSize,
                          color: const Color(0xFF4FC3F7),
                        ),
                      ),
                      SizedBox(height: headerGap),
                      Text('랜드마크 익스플로러',
                          style: titleStyle, textAlign: TextAlign.center),
                      SizedBox(height: compact ? 4 : 6),
                      Text(
                        '친구들과 함께 서울을 탐험하고\n새로운 추억을 만들어보세요!',
                        textAlign: TextAlign.center,
                        style: descStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: headerBottomGap),

                  // ===== 포인트 카드 3개(여백/아이콘 살짝 축소) =====
                  _FeatureCard(
                    dense: compact,
                    icon: Icons.pin_drop_outlined,
                    title: '랜드마크 탐험',
                    subtitle: '서울의 숨겨진 명소들을 발견해보세요',
                  ),
                  _FeatureCard(
                    dense: compact,
                    icon: Icons.groups_2_outlined,
                    title: '함께하는 모험',
                    subtitle: '새로운 사람들과 함께 미션을 완료하세요',
                  ),
                  _FeatureCard(
                    dense: compact,
                    icon: Icons.emoji_events_outlined,
                    title: '보상과 성취',
                    subtitle: '미션 완료 후 포인트와 배지를 획득하세요',
                  ),

                  SizedBox(height: compact ? 10 : 16),

                  // ✅ 로그인(이메일/비밀번호) 버튼 — 상단
                  OutlinedButton(
                    onPressed: onEmailLogin,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('로그인'),
                  ),

                  SizedBox(height: compact ? 10 : 14),

                  // '또는' 구분선
                  Row(
                    children: [
                      const Expanded(child: Divider(height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '또는',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(.6),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(height: 1)),
                    ],
                  ),

                  SizedBox(height: compact ? 10 : 14),

                  // Google 버튼
                  OutlinedButton(
                    onPressed: onGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.white,
                          child: Text(
                            'G',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Google로 시작하기'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Kakao 버튼
                  ElevatedButton(
                    onPressed: onKakaoSignIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                      backgroundColor: const Color(0xFFFEE500),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'K',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('카카오로 시작하기'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 회원가입
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('계정이 없으신가요? ', style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: onSignUp,
                        child: const Text('회원가입'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 약관
                  Text.rich(
                    TextSpan(
                      text: '로그인하면 ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(.6),
                      ),
                      children: [
                        TextSpan(
                          text: '이용약관',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '과 '),
                        TextSpan(
                          text: '개인정보처리방침',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '에 동의하는 것으로 간주됩니다.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7FAFF),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = dense ? 34.0 : 38.0; // 아이콘 박스 사이즈
    final margin = dense ? 8.0 : 12.0; // 카드 사이 여백
    final pad = dense ? 12.0 : 14.0; // 카드 안쪽 패딩
    final titleSize = dense ? 13.5 : null; // 타이틀 약간 축소
    final subSize = dense ? 12.0 : null;

    return Container(
      margin: EdgeInsets.only(bottom: margin),
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(.08)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 2),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: dense ? 20 : 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: subSize,
                    color: theme.colorScheme.onSurface.withOpacity(.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
