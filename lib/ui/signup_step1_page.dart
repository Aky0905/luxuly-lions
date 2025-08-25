// lib/ui/signup_step1_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ui/login_page.dart';

class SignupStep1Page extends StatefulWidget {
  const SignupStep1Page({super.key, this.hideEmail = false});
  final bool hideEmail; // (옵션) 외부로그인 후 이메일 필드를 숨길 때

  @override
  State<SignupStep1Page> createState() => _SignupStep1PageState();
}

class _SignupStep1PageState extends State<SignupStep1Page> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  // ⚠️ 실제 위치 권한 아님 — UI 상태만 저장
  bool _usePreciseLocation = false; // “정확한 위치 사용” 토글
  bool _agreeLocationCollection = false; // “위치 정보 수집 동의” 체크(필수)

  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 위치 수집 동의는 필수
    if (!_agreeLocationCollection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 정보 수집 및 이용에 동의해주세요.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final name = _nameCtrl.text.trim();

      // 이메일: hideEmail == false 이면 입력값, 아니면 이미 로그인 상태(소셜)에서 가져오기 시도
      String email = _emailCtrl.text.trim();
      if (widget.hideEmail) {
        email = FirebaseAuth.instance.currentUser?.email ?? '';
      }
      if (email.isEmpty) {
        throw FirebaseAuthException(
            code: 'invalid-email', message: '이메일이 비어있습니다.');
      }

      // 1) Auth 사용자 생성 (이메일/비밀번호)
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _pwCtrl.text,
      );

      // 2) 표시 이름 업데이트(선택)
      await cred.user?.updateDisplayName(name);

      // 3) Firestore에 프로필 저장 (UI의 위치 관련 설정도 함께)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'email': email,
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
        'usePreciseLocation': _usePreciseLocation,
        'agreeLocationCollection': _agreeLocationCollection,
        'status': 'active',
      });

      // 4) 요구사항: 가입 후 로그인 화면으로 돌아가게 → 즉시 로그아웃
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // 5) 완료 팝업
      await showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('회원가입 완료'),
          content: Text('가입이 완료되었습니다. 방금 만든 계정으로 로그인 해주세요.'),
        ),
      );

      // 5) 로그아웃은 네비게이션 직전 또는 직후에 수행해도 됨
      await FirebaseAuth.instance.signOut();

      // 6) 스택 전체 초기화 + 로그인 페이지 이동 (rootNavigator 사용)
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => '이미 사용 중인 이메일입니다.',
        'invalid-email' => '올바른 이메일 형식이 아닙니다.',
        'weak-password' => '비밀번호가 너무 약합니다.',
        'operation-not-allowed' => 'Firebase 콘솔에서 이메일/비밀번호 로그인을 활성화해주세요.',
        _ => '회원가입 중 오류가 발생했습니다. (${e.code})',
      };
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('알 수 없는 오류가 발생했습니다.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('회원가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // 헤더 박스
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: th.colorScheme.surface.withOpacity(.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            th.colorScheme.surfaceTint.withOpacity(.15),
                        child: const Icon(Icons.person_outline, size: 24),
                      ),
                      const SizedBox(height: 10),
                      Text('계정 정보를 입력해주세요',
                          style: th.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        '안전하고 편리한 서비스 이용을 위해 정확한 정보를 입력해주세요',
                        style: th.textTheme.bodySmall?.copyWith(
                          color: th.colorScheme.onSurface.withOpacity(.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 사용자명
                Text('사용자명', style: th.textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: '사용자명을 입력하세요',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '사용자명을 입력하세요';
                    if (v.trim().length < 2) return '2자 이상 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 이메일 (hideEmail=false일 때만 표시)
                if (!widget.hideEmail) ...[
                  Text('이메일', style: th.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'example@email.com',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '이메일을 입력하세요';
                      final ok =
                          RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                      return ok ? null : '올바른 이메일 형식이 아닙니다';
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // 비밀번호
                Text('비밀번호', style: th.textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pwCtrl,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    hintText: '8자 이상의 비밀번호',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '비밀번호를 입력하세요';
                    if (v.length < 8) return '8자 이상 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 비밀번호 확인
                Text('비밀번호 확인', style: th.textTheme.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pw2Ctrl,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 다시 입력하세요',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) {
                    if (v != _pwCtrl.text) return '비밀번호가 일치하지 않습니다';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // 위치 정보 접근 허용 + 상태 칩 + 토글 (UI 전용)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: th.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: th.colorScheme.outline.withOpacity(.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('위치 정보 접근 허용',
                                    style: th.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _usePreciseLocation
                                        ? Colors.green.withOpacity(.15)
                                        : th.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    _usePreciseLocation ? '활성' : '비활성',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _usePreciseLocation
                                          ? Colors.green.shade700
                                          : th.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('현재 위치 기반으로 주변 맞춤 미션을 추천받으세요',
                                style: th.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Switch(
                        value: _usePreciseLocation,
                        onChanged: (v) =>
                            setState(() => _usePreciseLocation = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 안내 배너 (선택)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE3A5)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, color: Color(0xFFDAA300)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('위치 정보를 허용하면 주변 맞춤 미션을 더 정확하게 추천받을 수 있어요!'),
                      ),
                    ],
                  ),
                ),

                // 위치 정보 수집 동의 (필수)
                CheckboxListTile(
                  value: _agreeLocationCollection,
                  onChanged: (v) =>
                      setState(() => _agreeLocationCollection = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('위치 정보 수집 및 이용에 동의'),
                  subtitle: const Text('동의해야 회원가입을 진행할 수 있어요.'),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 12),

                // ✅ 버튼 문구 변경: “회원가입 완료”
                FilledButton(
                  onPressed: (_loading || !_agreeLocationCollection)
                      ? null
                      : _onSubmit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('회원가입 완료'),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7FAFF),
    );
  }
}
