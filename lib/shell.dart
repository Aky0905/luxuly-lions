// lib/shell.dart
import 'package:flutter/material.dart';

// 📌 탭 화면들
import 'screens/home_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/rewards_shop_screen.dart'; // 상점 화면

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),        // 0
    MissionScreen(),     // 1
    RewardsShopScreen(), // 2 (상점)
    ProfileScreen(),     // 3
    SettingsScreen(),    // 4
  ];

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBtn(
              icon: Icons.home_outlined,
              active: Icons.home,
              label: '홈',
              isSelected: _index == 0,
              onTap: () => _go(0),
            ),
            _NavBtn(
              icon: Icons.flag_outlined,
              active: Icons.flag,
              label: '미션',
              isSelected: _index == 1,
              onTap: () => _go(1),
            ),
            _NavBtn(
              icon: Icons.storefront_outlined,
              active: Icons.storefront,
              label: '교환소',
              isSelected: _index == 2,
              onTap: () => _go(2),
            ),
            _NavBtn(
              icon: Icons.person_outline,
              active: Icons.person,
              label: '프로필',
              isSelected: _index == 3,
              onTap: () => _go(3),
            ),
            _NavBtn(
              icon: Icons.settings_outlined,
              active: Icons.settings,
              label: '설정',
              isSelected: _index == 4,
              onTap: () => _go(4),
            ),
          ],
        ),
      ),
    );
  }
}

/// ───────────────────── 하단바 버튼 위젯 ─────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final IconData active;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBtn({
    super.key,
    required this.icon,
    required this.active,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.black54;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ overflow 방지
          children: [
            Icon(isSelected ? active : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: color, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
