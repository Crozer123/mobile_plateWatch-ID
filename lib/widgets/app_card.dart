import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';

/// Kartu bergaya stiker "Kawaii Pop": sudut 24px, border tegas 2px, dan hard-offset shadow padat.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final double radius;
  final double shadowOffset;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.shadowColor,
    this.radius = 24,
    this.shadowOffset = 4,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppColors.elevated,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? AppColors.border, width: 2),
          boxShadow: shadowOffset <= 0
              ? null
              : [
                  BoxShadow(
                    color: shadowColor ?? AppColors.cardShadow,
                    offset: Offset(0, shadowOffset),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: child,
      );
}

/// Badge kapsul penuh (`999px`) dengan border lembut & warna harmonis.
class Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color? borderColor;
  final IconData? icon;
  const Pill(
    this.text, {
    super.key,
    required this.bg,
    required this.fg,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor ?? fg.withValues(alpha: .22), width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
            ),
          ),
        ]),
      );
}

enum SquishyVariant { primary, secondary, peach, butter, danger, success }

/// Tombol pil membal (Squishy Tactile Button) dengan shadow padat yang tertekan saat diklik.
class SquishyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final SquishyVariant variant;
  final bool fullWidth;
  final bool compact;

  const SquishyButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = SquishyVariant.primary,
    this.fullWidth = true,
    this.compact = false,
  });

  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton> {
  bool _pressed = false;

  (Color bg, Color fg, Color border, Color shadow) _palette() {
    switch (widget.variant) {
      case SquishyVariant.primary:
        return (AppColors.primary, Colors.white, AppColors.primaryShadow, AppColors.primaryShadow);
      case SquishyVariant.secondary:
        return (AppColors.elevated, AppColors.textDark, AppColors.border, AppColors.cardShadow);
      case SquishyVariant.peach:
        return (AppColors.peach, AppColors.peachInk, AppColors.peachShadow, AppColors.peachShadow);
      case SquishyVariant.butter:
        return (AppColors.butter, AppColors.butterInk, AppColors.butterShadow, AppColors.butterShadow);
      case SquishyVariant.danger:
        return (AppColors.danger, Colors.white, const Color(0xFF721C29), const Color(0xFF721C29));
      case SquishyVariant.success:
        return (AppColors.success, Colors.white, const Color(0xFF1F4B37), const Color(0xFF1F4B37));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final (bg, fg, border, shadow) = _palette();
    final dy = (!enabled || _pressed) ? 3.0 : 0.0;
    final sh = !enabled ? 0.0 : (_pressed ? 1.0 : 4.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: AnimatedContainer(
          duration: AppTheme.bouncyDuration,
          curve: AppTheme.bouncyCurve,
          width: widget.fullWidth ? double.infinity : null,
          transform: Matrix4.translationValues(0, dy, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 20,
            vertical: widget.compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: _pressed && widget.variant == SquishyVariant.primary ? AppColors.primaryDark : bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: 2),
            boxShadow: sh <= 0
                ? null
                : [BoxShadow(color: shadow, offset: Offset(0, sh), blurRadius: 0)],
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.compact ? 16 : 19, color: fg),
                SizedBox(width: widget.compact ? 6 : 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.compact ? 12.5 : 14.5,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper efek membal lembut untuk kartu yang bisa ditekan.
class SquishyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const SquishyTap({super.key, required this.child, this.onTap});

  @override
  State<SquishyTap> createState() => _SquishyTapState();
}

class _SquishyTapState extends State<SquishyTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: AppTheme.bouncyDuration,
        curve: AppTheme.bouncyCurve,
        transform: Matrix4.translationValues(0, _pressed ? 2.5 : 0.0, 0),
        child: widget.child,
      ),
    );
  }
}
