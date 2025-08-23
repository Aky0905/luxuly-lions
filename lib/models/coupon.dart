class Coupon {
  final String id;              // 고유 ID
  final String title;
  final String description;
  final DateTime issuedAt;

  bool isUsed;                  // 사용 여부
  DateTime? usedAt;             // 사용 시각
  final String code;            // 바코드/QR에 쓸 코드 문자열

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.issuedAt,
    required this.code,
    this.isUsed = false,
    this.usedAt,
  });
}
