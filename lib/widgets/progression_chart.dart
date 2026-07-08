import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small embedded round-by-round score chart: a leader line (strong, thick)
/// and a runner-up line (muted, thin) over a faint decorative bar backdrop.
///
/// Rank is encoded by both color weight *and* line thickness so the two
/// series stay distinguishable without relying on color alone.
class ProgressionChart extends StatelessWidget {
  const ProgressionChart({
    super.key,
    required this.leaderSeries,
    required this.runnerUpSeries,
    required this.roundLabels,
  });

  final List<int> leaderSeries;
  final List<int> runnerUpSeries;
  final List<String> roundLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: CustomPaint(
            painter: _ProgressionPainter(
              leaderSeries: leaderSeries,
              runnerUpSeries: runnerUpSeries,
              barCount: roundLabels.length,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < roundLabels.length; i++)
              Expanded(
                child: Center(
                  child: Text(
                    roundLabels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: i == roundLabels.length - 1 ? FontWeight.w700 : FontWeight.w500,
                      color: i == roundLabels.length - 1
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProgressionPainter extends CustomPainter {
  _ProgressionPainter({
    required this.leaderSeries,
    required this.runnerUpSeries,
    required this.barCount,
  });

  final List<int> leaderSeries;
  final List<int> runnerUpSeries;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (barCount == 0) return;
    final columnWidth = size.width / barCount;

    final maxValue =
        [...leaderSeries, ...runnerUpSeries].reduce((a, b) => a > b ? a : b) * 1.15;

    _drawBars(canvas, size, columnWidth);
    _drawLine(canvas, size, columnWidth, runnerUpSeries, maxValue, AppColors.chartRunnerUpLine, 2.5);
    _drawLine(canvas, size, columnWidth, leaderSeries, maxValue, AppColors.chartLeaderLine, 3.5);
  }

  void _drawBars(Canvas canvas, Size size, double columnWidth) {
    final paint = Paint()..color = AppColors.chartBarFill;
    for (int i = 0; i < barCount; i++) {
      final heightFraction = 0.25 + (i / (barCount - 1).clamp(1, barCount)) * 0.55;
      final barHeight = size.height * heightFraction;
      final centerX = columnWidth * (i + 0.5);
      final barWidth = columnWidth * 0.5;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, size.height - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    double columnWidth,
    List<int> series,
    double maxValue,
    Color color,
    double strokeWidth,
  ) {
    if (series.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    const topInset = 8.0;
    final usableHeight = size.height - topInset;

    for (int i = 0; i < series.length; i++) {
      final x = columnWidth * (i + 0.5);
      final y = topInset + usableHeight * (1 - series[i] / maxValue);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ProgressionPainter oldDelegate) {
    return oldDelegate.leaderSeries != leaderSeries || oldDelegate.runnerUpSeries != runnerUpSeries;
  }
}
