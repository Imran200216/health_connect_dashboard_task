import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_connect_dashboard/features/home/presentation/bloc/health_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Health Dashboard",
          style: GoogleFonts.googleSans(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            // 🔄 Loading state
            if (state is HealthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ❌ Error state
            if (state is HealthError) {
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              );
            }

            // ✅ Loaded state
            if (state is HealthLoaded) {
              final totalSteps = state.weeklySteps.fold(0, (a, b) => a + b);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ❤️ Heart Rate
                    Text(
                      "${state.heartRate} bpm",
                      style: GoogleFonts.googleSans(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Current Heart Rate",
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 👣 Steps
                    Text(
                      totalSteps.toString(),
                      style: GoogleFonts.googleSans(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total Steps This Week",
                      style: GoogleFonts.googleSans(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 📈 Steps Chart (FIXED SIZE)
                    Expanded(
                      child: CustomPaint(
                        painter: StepLineChartPainter(state.weeklySteps),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// 📊 Custom Painter for Steps Line Chart
class StepLineChartPainter extends CustomPainter {
  final List<int> steps;

  StepLineChartPainter(this.steps);

  @override
  void paint(Canvas canvas, Size size) {
    if (steps.isEmpty) return;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    int maxSteps = steps.reduce((a, b) => a > b ? a : b);
    if (maxSteps == 0) maxSteps = 1;

    // ── Horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height - (i * size.height / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final spacing = size.width / (steps.length - 1);
    final path = Path();

    for (int i = 0; i < steps.length; i++) {
      final x = spacing * i;
      final y = size.height - (steps[i] / maxSteps) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, linePaint);

    // ── X-axis labels
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final textStyle = GoogleFonts.googleSans(fontSize: 12, color: Colors.black);

    for (int i = 0; i < steps.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: days[i], style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      final x = spacing * i - tp.width / 2;
      final y = size.height + 4;
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
