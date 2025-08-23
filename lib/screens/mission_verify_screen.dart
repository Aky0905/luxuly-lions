import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../state/user_progress.dart';

class MissionVerifyScreen extends StatefulWidget {
  final String title;
  final int rewardPoint; // 예: 400
  const MissionVerifyScreen({super.key, required this.title, required this.rewardPoint});

  @override
  State<MissionVerifyScreen> createState() => _MissionVerifyScreenState();
}

class _MissionVerifyScreenState extends State<MissionVerifyScreen> {
  bool gpsVerified = false;        // 데모: 버튼으로 인증
  File? photo;
  final _note = TextEditingController();

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => photo = File(img.path));
  }

  void _fakeGpsVerify() {
    // 데모용 GPS 인증 (실제는 geolocator 등으로 구현)
    setState(() => gpsVerified = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS 인증 완료')));
  }

  void _submit() {
    if (!gpsVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS 인증을 완료해주세요')));
      return;
    }
    // 완료 처리 + 포인트 지급
    UserProgress().completeMission(widget.rewardPoint);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('인증 성공! +${widget.rewardPoint}P 적립')),
    );
    Navigator.of(context).pop(true); // true = 인증 완료됨
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미션 인증하기')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          // 1) GPS 인증
          Card(
            child: ListTile(
              leading: Icon(gpsVerified ? Icons.check_circle : Icons.my_location),
              title: const Text('GPS 인증'),
              subtitle: Text(gpsVerified ? '인증 완료' : '현재 위치를 확인해 인증하세요 (데모)'),
              trailing: FilledButton(
                onPressed: gpsVerified ? null : _fakeGpsVerify,
                child: Text(gpsVerified ? '완료' : '인증하기'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2) 사진 업로드 (선택)
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('사진 인증 (선택)'),
              subtitle: Text(photo == null ? '갤러리에서 사진 선택' : '사진이 첨부되었습니다'),
              trailing: OutlinedButton(onPressed: _pickPhoto, child: const Text('사진 선택')),
            ),
          ),
          if (photo != null) ...[
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(photo!, height: 180, fit: BoxFit.cover)),
          ],
          const SizedBox(height: 12),

          // 3) 메모
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '미션 설명/메모 (선택)'),
          ),
          const SizedBox(height: 16),

          // 제출
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text('인증 제출하고 +${widget.rewardPoint}P 받기'),
          ),
        ],
      ),
    );
  }
}
