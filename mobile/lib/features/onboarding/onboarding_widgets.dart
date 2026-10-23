import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/widgets.dart';

/// Floating "banknotes" and a coin from the onboarding mockup.
class BanknotesIllustration extends StatefulWidget {
  const BanknotesIllustration({super.key, this.height = 220});

  final double height;

  @override
  State<BanknotesIllustration> createState() => _BanknotesIllustrationState();
}

class _BanknotesIllustrationState extends State<BanknotesIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion(context) && !_float.isAnimating) _float.repeat();
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget note({required Gradient gradient, required double angle, required double top, required Color shadow, Widget? child}) =>
        Positioned(
          top: top,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              width: 230,
              height: 128,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: shadow, blurRadius: 60, offset: const Offset(0, 30), spreadRadius: -20)],
              ),
              child: child,
            ),
          ),
        );

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, _) {
          final t = _float.value * 2 * pi;
          return Stack(alignment: Alignment.topCenter, clipBehavior: Clip.none, children: [
            note(
              gradient: const LinearGradient(colors: [AppColors.ink, Color(0xFF2D2190)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              angle: -14 * pi / 180 + sin(t) * 0.02,
              top: 50 + sin(t) * 4,
              shadow: AppColors.ink.withValues(alpha: 0.6),
            ),
            note(
              gradient: const LinearGradient(colors: [AppColors.dollarLight, AppColors.dollar, Color(0xFF3E7A2A)], stops: [0, 0.45, 1], begin: Alignment.topLeft, end: Alignment.bottomRight),
              angle: 7 * pi / 180 + cos(t) * 0.02,
              top: 72 + cos(t) * 4,
              shadow: AppColors.dollar.withValues(alpha: 0.5),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('BYN · USD · EUR', style: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xB30B0D12))),
                Text('12 480 Br', style: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w700, fontSize: 26, color: AppColors.onBright)),
              ]),
            ),
            Positioned(
              top: 26 + sin(t + 1) * 6,
              right: MediaQuery.sizeOf(context).width / 2 - 150,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFFFE7A3), AppColors.gold, Color(0xFFB9852A)], stops: [0, 0.55, 1]),
                  boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.7), blurRadius: 30, offset: const Offset(0, 14), spreadRadius: -10)],
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

/// Three progress dots: done = green, current = long violet.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.step, this.total = 3});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(children: [
      for (var i = 1; i <= total; i++) ...[
        AnimatedContainer(
          duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 350),
          width: i == step ? 32 : 12,
          height: 6,
          decoration: BoxDecoration(
            color: i < step ? AppColors.dollar : i == step ? AppColors.inkLight : c.track,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
      ],
    ]);
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.of(context).textSecondary)),
      );
}
