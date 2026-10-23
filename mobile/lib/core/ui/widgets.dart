import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_icons.dart';

bool reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Scales to 0.96 while pressed (150 ms), as in the design.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.onLongPress, this.semanticLabel});

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (widget.onTap != null && _down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Surface + 1px outline, no shadow.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 22, this.color, this.border});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  /// Only a uniform [Border] is supported (its top side is used).
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final side = border is Border ? (border! as Border).top : BorderSide(color: c.outline);
    // A Material (not a decorated box), so list tiles inside keep their ink splashes.
    return Material(
      color: color ?? c.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: side),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Square icon tile: the icon on its color at ~14% alpha.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.color, this.size = 42, this.radius = 14, this.iconSize = 22});

  final String icon;
  final Color color;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.tile(color), borderRadius: BorderRadius.circular(radius)),
        child: AppIcon(icon, size: iconSize, color: color),
      );
}

/// 44×44 surface button with an icon (header actions).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({super.key, required this.icon, required this.onTap, required this.label, this.badge});

  final String icon;
  final VoidCallback? onTap;
  final String label;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.outline)),
          child: AppIcon(icon, color: c.textPrimary, size: 20),
        ),
        if (badge != null) Positioned(top: -4, right: -4, child: badge!),
      ]),
    );
  }
}

/// The main call to action (gradient), 56 high.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false, this.gradient, this.foreground});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final Gradient? gradient;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final fg = foreground ?? Colors.white;
    return Opacity(
      opacity: enabled || busy ? 1 : 0.45,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        semanticLabel: label,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(gradient: gradient ?? AppColors.primaryGradient, borderRadius: BorderRadius.circular(18)),
          child: busy
              ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
              : Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: fg)),
        ),
      ),
    );
  }
}

/// A selectable pill / option button.
class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 40,
    this.radius = 999,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final double radius;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 200),
        height: height,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.ink.withValues(alpha: 0.22) : c.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: selected ? AppColors.inkLight : c.outline),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? (dark ? const Color(0xFFD4CEFF) : AppColors.inkDark) : c.textSecondary,
            ),
          ),
        ]),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(action!, style: TextStyle(fontSize: 14, color: c.accentText, fontWeight: FontWeight.w500)),
          ),
        ),
    ]);
  }
}

/// Base color with one or two soft radial glows in the top corners.
class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child, this.tint});

  final Widget child;

  /// Overrides the primary glow (quick add tints it by operation type).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.background),
      child: Stack(children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1, -1),
                  radius: 1.1,
                  colors: [tint ?? c.glowPrimary, Colors.transparent],
                  stops: const [0, 0.6],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-1, -0.55),
                  radius: 0.8,
                  colors: [c.glowSecondary, Colors.transparent],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
        ),
        child,
      ]),
    );
  }
}

/// Fades and rises in on first build (700 ms, cubic(.2,.8,.2,1)); staggered by [index].
class RiseIn extends StatefulWidget {
  const RiseIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final Animation<double> _t = CurvedAnimation(parent: _controller, curve: const Cubic(0.2, 0.8, 0.2, 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.status == AnimationStatus.dismissed) {
      if (reduceMotion(context)) {
        _controller.value = 1;
      } else {
        Future.delayed(Duration(milliseconds: 75 * widget.index), () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        builder: (context, child) => Opacity(
          opacity: _t.value,
          child: Transform.translate(offset: Offset(0, 14 * (1 - _t.value)), child: child),
        ),
        child: widget.child,
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action, this.onAction});

  final String icon;
  final String title;
  final String? message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        IconTile(icon: icon, color: c.textSecondary, size: 56, radius: 18, iconSize: 26),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(message!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
        if (action != null) ...[
          const SizedBox(height: 16),
          ChoiceButton(label: action!, selected: true, onTap: onAction ?? () {}),
        ],
      ]),
    );
  }
}

/// Shows a modal bottom sheet in the app style.
Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: builder(context),
      ),
    );
