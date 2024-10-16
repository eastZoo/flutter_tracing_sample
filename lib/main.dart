import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const TracingApp());

class TracingApp extends StatelessWidget {
  const TracingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TracingScreen(),
    );
  }
}

class TracingScreen extends StatefulWidget {
  const TracingScreen({super.key});

  @override
  _TracingScreenState createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  List<Offset> userPoints = [];
  bool stroke1Complete = false;
  bool stroke2Complete = false;
  bool isComplete = false;

  // Define points for strokes of "ㄱ"
  final List<Offset> stroke1Points = [
    const Offset(100, 100),
    const Offset(100, 300)
  ];
  final List<Offset> stroke2Points = [
    const Offset(100, 300),
    const Offset(300, 300)
  ];
  final double tolerance = 20.0;

  // Track if user has passed the start and is moving toward the end
  bool isStroke1InProgress = false;
  bool isStroke2InProgress = false;

  // Check if the traced point is near the stroke points
  bool _isNearStroke(Offset start, Offset end, Offset point) {
    return (point - start).distance < tolerance ||
        (point - end).distance < tolerance;
  }

  // Detect if strokes are correctly traced
  void _checkStrokeCompletion(Offset point) {
    // Stroke 1: only complete when the user touches both start and end sequentially
    if (!stroke1Complete && !isStroke1InProgress) {
      // Detect if user is near the start of stroke 1
      if ((point - stroke1Points[0]).distance < tolerance) {
        isStroke1InProgress = true; // Stroke 1 has started
      }
    } else if (!stroke1Complete && isStroke1InProgress) {
      // Detect if user reaches the end of stroke 1
      if ((point - stroke1Points[1]).distance < tolerance) {
        setState(() {
          stroke1Complete = true;
          isStroke1InProgress = false;
        });
      }
    }

    // Stroke 2: only complete when stroke 1 is done and the user follows the correct path
    if (stroke1Complete && !stroke2Complete && !isStroke2InProgress) {
      if ((point - stroke2Points[0]).distance < tolerance) {
        isStroke2InProgress = true; // Stroke 2 has started
      }
    } else if (stroke1Complete && isStroke2InProgress) {
      if ((point - stroke2Points[1]).distance < tolerance) {
        setState(() {
          stroke2Complete = true;
          isStroke2InProgress = false;
          _checkCompletion();
        });
      }
    }

    setState(() {
      userPoints.add(point); // Add user touch point in real-time
    });
  }

  void _checkCompletion() {
    if (stroke1Complete && stroke2Complete) {
      setState(() {
        isComplete = true;
      });
      // Delay the success modal by 500ms to allow the final stroke to be filled
      Future.delayed(const Duration(milliseconds: 500), () {
        _showSuccessModal();
      });
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("성공!"),
        content: const Text("모든 라인을 정확히 그렸습니다."),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                userPoints.clear();
                stroke1Complete = false;
                stroke2Complete = false;
                isComplete = false;
              });
              Navigator.of(context).pop();
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('한글 "ㄱ" 따라 그리기')),
      body: GestureDetector(
        onPanUpdate: (details) {
          _checkStrokeCompletion(details.localPosition);
        },
        child: CustomPaint(
          painter: TracingPainter(userPoints, stroke1Complete, stroke2Complete),
          child: const SizedBox(
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

class TracingPainter extends CustomPainter {
  final List<Offset> points;
  final bool stroke1Complete;
  final bool stroke2Complete;

  TracingPainter(this.points, this.stroke1Complete, this.stroke2Complete);

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    Paint completePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    Paint tracePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Paint arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Draw the expected strokes
    canvas.drawLine(
        const Offset(100, 100), const Offset(100, 300), strokePaint);
    canvas.drawLine(
        const Offset(100, 300), const Offset(300, 300), strokePaint);

    // Draw arrows for guidance
    _drawArrow(canvas, arrowPaint, const Offset(100, 100),
        const Offset(100, 300)); // First stroke arrow
    _drawArrow(canvas, arrowPaint, const Offset(100, 300),
        const Offset(300, 300)); // Second stroke arrow

    // Draw completed strokes
    if (stroke1Complete) {
      canvas.drawLine(
          const Offset(100, 100), const Offset(100, 300), completePaint);
    }
    if (stroke2Complete) {
      canvas.drawLine(
          const Offset(100, 300), const Offset(300, 300), completePaint);
    }

    // Draw user's tracing in real-time
    if (points.isNotEmpty) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], tracePaint);
      }
    }
  }

  // Helper to draw arrows
  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    const double arrowSize = 10.0;
    final double angle = (end - start).direction;
    canvas.drawLine(start, end, paint);

    final Offset arrowTip1 = Offset(
      end.dx - arrowSize * cos(angle - 3.14 / 6),
      end.dy - arrowSize * sin(angle - 3.14 / 6),
    );
    final Offset arrowTip2 = Offset(
      end.dx - arrowSize * cos(angle + 3.14 / 6),
      end.dy - arrowSize * sin(angle + 3.14 / 6),
    );

    canvas.drawLine(end, arrowTip1, paint);
    canvas.drawLine(end, arrowTip2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
