import 'package:flutter/material.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  final _controller = TextEditingController(text: '강남구 · 서울특별시');

  void _apply(String value) {
    Navigator.of(context).pop(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위치 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '예) 강남구 · 서울특별시',
                labelText: '현재 위치(수동 입력)',
              ),
              onSubmitted: _apply,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                // 데모용 GPS 인증: 강남구로 설정
                _controller.text = '강남구 · 서울특별시';
                _apply(_controller.text);
              },
              icon: const Icon(Icons.my_location),
              label: const Text('GPS 인증하기 (데모)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _apply(_controller.text),
              child: const Text('이 위치로 설정'),
            ),
          ],
        ),
      ),
    );
  }
}
