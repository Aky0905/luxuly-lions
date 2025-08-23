// lib/screens/rewards_shop_screen.dart
import 'package:flutter/material.dart';
import '../state/points_state.dart';
import 'rewards_item_detail_screen.dart';

class RewardsShopScreen extends StatefulWidget {
  /// 현재 지역 텍스트 (예: "강남구 · 서울특별시")
  final String? currentArea;
  const RewardsShopScreen({super.key, this.currentArea});

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen> {
  final _q = TextEditingController();
  String _selectedCat = '전체';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = _demoCatalog;
    final area = _extractArea(widget.currentArea ?? '');
    final filtered = all.where((it) {
      // 지역 매칭(데모): 아이템의 area가 비어있거나, 현재 구/동을 포함하면 노출
      final areaOk = it.area.isEmpty || area.isEmpty || it.area.contains(area);
      // 카테고리
      final catOk = _selectedCat == '전체' || it.category == _selectedCat;
      // 검색어(제목/파트너/태그)
      final q = _q.text.trim().toLowerCase();
      final searchOk = q.isEmpty ||
          it.title.toLowerCase().contains(q) ||
          it.partner.toLowerCase().contains(q) ||
          it.tags.any((t) => t.toLowerCase().contains(q));
      return areaOk && catOk && searchOk;
    }).toList();

    final cats = <String>['전체', '카페', '식당', '편의점', '문화/여가', '기타'];

    return Scaffold(
      appBar: AppBar(title: const Text('교환소')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (area.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.my_location, size: 18),
                          const SizedBox(width: 6),
                          Text('$area 근처 상점',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _q,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '카페/식당/편의점/커피/음료… 검색',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in cats)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: _selectedCat == c,
                                onSelected: (_) =>
                                    setState(() => _selectedCat = c),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .74, // ⬅️ 여유 있게 조정 (기존 .78)
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final it = filtered[i];
                    return _ShopCard(
                      item: it,
                      onTapBuy: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RewardsItemDetailScreen(
                              id: it.id,
                              title: it.title,
                              partner: it.partner,
                              category: it.category,
                              cost: it.cost,
                              area: it.area,
                              desc: it.desc,
                              emoji: it.emoji,
                              tags: it.tags,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _extractArea(String s) {
    // "강남구 · 서울특별시" -> "강남구"
    if (s.contains('·')) return s.split('·').first.trim();
    return s.trim();
  }
}

/// ── 카드 UI ────────────────────────────────────────────────────────────────
class _ShopCard extends StatelessWidget {
  final _ShopItem item;
  final VoidCallback onTapBuy;
  const _ShopCard({required this.item, required this.onTapBuy});

  @override
  Widget build(BuildContext context) {
    final balance = PointsState().balance;
    final canBuy = balance >= item.cost;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTapBuy, // 상세는 항상 열림
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            // ⬅️ Spacer 대신 spaceBetween으로 안전 배치
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일 살짝 낮춤 (92 → 88)
              Container(
                height: 88,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item.emoji, style: const TextStyle(fontSize: 36)),
              ),

              // 제목
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),

              // 파트너/카테고리
              Text(
                '${item.partner} • ${item.category}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),

              // 가격 + 버튼
              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${item.cost}P'),
                  ),
                  const Spacer(),
                  // 색으로만 가능/불가 표현 (텍스트는 항상 '교환')
                  FilledButton(
                    onPressed: onTapBuy, // 상세로 이동
                    style: FilledButton.styleFrom(
                      backgroundColor: canBuy
                          ? null // 기본(보라) → 가능
                          : Colors.grey.shade300, // 불가(회색)
                      foregroundColor:
                      canBuy ? null : Colors.grey.shade600, // 텍스트색
                      minimumSize: const Size(84, 38), // 버튼 살짝 낮춤
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('교환'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiThumb extends StatelessWidget {
  final String emoji;
  const _EmojiThumb({required this.emoji});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 36)),
    );
  }
}

/// ── 데모 데이터 ────────────────────────────────────────────────────────────
/// 포인트 정책(현실감): 커피 2,500P / 디저트 3,200P / 식사 6,000P / 편의점 1,200P / 문화 9,000~12,000P
class _ShopItem {
  final String id;
  final String title;
  final String partner;
  final String category; // 카페/식당/편의점/문화/기타
  final int cost; // 포인트
  final String area; // "강남구" 등 (비어있으면 전국)
  final List<String> tags;
  final String desc;
  final String emoji; // 데모용 썸네일

  const _ShopItem({
    required this.id,
    required this.title,
    required this.partner,
    required this.category,
    required this.cost,
    this.area = '',
    this.tags = const [],
    this.desc = '',
    this.emoji = '🎁',
  });
}

const _demoCatalog = <_ShopItem>[
  _ShopItem(
    id: 'cafe-ame',
    title: '아메리카노 1잔',
    partner: '동네카페',
    category: '카페',
    cost: 2500,
    area: '강남구',
    tags: ['커피', '음료', '카페'],
    desc: '매장 방문 포장/일부 매장 제외',
    emoji: '☕️',
  ),
  _ShopItem(
    id: 'dessert',
    title: '케이크 조각',
    partner: '베이커리',
    category: '카페',
    cost: 3200,
    area: '서초구',
    tags: ['디저트', '케이크', '카페'],
    desc: '당일 한정, 일부 품목 제외',
    emoji: '🍰',
  ),
  _ShopItem(
    id: 'meal-bowl',
    title: '덮밥 단품',
    partner: '골목식당',
    category: '식당',
    cost: 6000,
    area: '강남구',
    tags: ['식사', '한식', '점심'],
    desc: '런치 타임 사용 권장',
    emoji: '🍛',
  ),
  _ShopItem(
    id: 'cvs-drink',
    title: '편의점 캔음료 1개',
    partner: 'CU/GS25',
    category: '편의점',
    cost: 1200,
    area: '',
    tags: ['편의점', '음료'],
    desc: '일부 특수점 제외',
    emoji: '🥤',
  ),
  _ShopItem(
    id: 'museum',
    title: '전시관 입장권 -20%',
    partner: '지역 박물관',
    category: '문화/여가',
    cost: 9000,
    area: '송파구',
    tags: ['문화', '전시', '데이트'],
    desc: '성인 기준, 특정 전시는 제외될 수 있음',
    emoji: '🖼️',
  ),
  _ShopItem(
    id: 'aqua',
    title: '아쿠아리움 -20%',
    partner: '코엑스 아쿠아리움',
    category: '문화/여가',
    cost: 12000,
    area: '강남구',
    tags: ['아쿠아리움', '가족', '데이트'],
    desc: '온라인 사전 예매 권장',
    emoji: '🐠',
  ),
];
