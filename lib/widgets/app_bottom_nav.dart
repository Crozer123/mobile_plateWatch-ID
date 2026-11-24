import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final int activeCount;
  const AppBottomNav({super.key, required this.index, required this.onTap, this.activeCount = 0});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.qr_code_scanner_rounded, 'Scanner', 0),
      (Icons.two_wheeler_rounded, 'Parkir Aktif', activeCount),
      (Icons.history_rounded, 'Riwayat', 0),
    ];
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: AppColors.primary.withOpacity(.08), blurRadius: 16, offset: const Offset(0, -4)),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(clipBehavior: Clip.none, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: index == i ? AppColors.pink : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(items[i].$1, size: 22, color: index == i ? AppColors.pinkDark : AppColors.textMuted),
                  ),
                  if (items[i].$3 > 0)
                    Positioned(
                      right: 2,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.pinkDark, borderRadius: BorderRadius.circular(10)),
                        child: Text('${items[i].$3}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ]),
                const SizedBox(height: 3),
                Text(items[i].$2,
                    style: TextStyle(fontSize: 11, fontWeight: index == i ? FontWeight.w700 : FontWeight.w500,
                        color: index == i ? AppColors.primaryDark : AppColors.textMuted)),
              ]),
            ),
        ],
      ),
    );
  }
}
