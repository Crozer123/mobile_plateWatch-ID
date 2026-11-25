import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final int activeCount;
  const AppBottomNav({super.key, required this.index, required this.onTap, this.activeCount = 0});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.qr_code_scanner_rounded, 'Scanner', 0),
      (Icons.dashboard_rounded, 'Dashboard', activeCount),
      (Icons.history_rounded, 'Riwayat', 0),
    ];
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.elevated,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
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
                    duration: AppTheme.bouncyDuration,
                    curve: AppTheme.bouncyCurve,
                    transform: Matrix4.translationValues(0, index == i ? -2 : 0, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: index == i ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: index == i ? AppColors.primaryShadow : AppColors.border,
                        width: 2,
                      ),
                      boxShadow: index == i
                          ? const [BoxShadow(color: AppColors.primaryShadow, offset: Offset(0, 3), blurRadius: 0)]
                          : null,
                    ),
                    child: Icon(
                      items[i].$1,
                      size: 21,
                      color: index == i ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                  if (items[i].$3 > 0)
                    Positioned(
                      right: -2,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.peach,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.peachShadow, width: 1.5),
                        ),
                        child: Text(
                          '${items[i].$3}',
                          style: const TextStyle(color: AppColors.peachInk, fontSize: 9.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 5),
                Text(
                  items[i].$2,
                  style: index == i
                      ? AppTheme.heading(size: 12, color: AppColors.primaryDark)
                      : AppTheme.body(size: 11, w: FontWeight.w600, color: AppColors.textMuted, height: 1.2),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
