import 'package:flutter/material.dart';

class PortalBackground extends StatelessWidget {
  final Widget child;
  const PortalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0F2547);
    const gold = Color(0xFFD4AF37);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8EEF9),
            Color(0xFFF3F6FC),
            Color(0xFFFAF6EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PortalBlueprintPainter(),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -110,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withValues(alpha: 0.22),
                    width: 22,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -90,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: navy.withValues(alpha: 0.04),
                  border: Border.all(
                    color: navy.withValues(alpha: 0.07),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PortalBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF0F2547).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final goldRayPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.13)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width * 0.65, size.height),
      Offset(size.width, size.height * 0.55),
      goldRayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height),
      Offset(size.width, size.height * 0.68),
      goldRayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PortalHeroHeader extends StatelessWidget {
  final Widget child;
  final double bottomPadding;
  final double maxWidth;
  final bool fullWidth;

  const PortalHeroHeader({
    super.key,
    required this.child,
    this.bottomPadding = 28,
    this.maxWidth = 860,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    final isWide = MediaQuery.of(context).size.width >= 768;
    final horizontalPad = fullWidth && isWide ? 36.0 : 24.0;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF071124),
            Color(0xFF0F2547),
            Color(0xFF1B3F7A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gold.withValues(alpha: 0.22),
                    gold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              MediaQuery.of(context).padding.top + 20,
              horizontalPad,
              bottomPadding,
            ),
            child: fullWidth
                ? child
                : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PortalResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final bool fullWidth;

  const PortalResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    final horizontalPad = fullWidth && isWideScreen ? 36.0 : 24.0;

    Widget buildGrid(BoxConstraints constraints) {
      final isWide = constraints.maxWidth >= 640;
      if (!isWide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) SizedBox(height: spacing),
            ],
          ],
        );
      }

      final rows = <Widget>[];
      for (int i = 0; i < children.length; i += 2) {
        final hasSecond = i + 1 < children.length;
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                SizedBox(width: spacing),
                Expanded(
                  child: hasSecond ? children[i + 1] : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
        if (i + 2 < children.length) {
          rows.add(SizedBox(height: spacing));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
      child: fullWidth
          ? LayoutBuilder(builder: (context, c) => buildGrid(c))
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: LayoutBuilder(builder: (context, c) => buildGrid(c)),
        ),
      ),
    );
  }
}