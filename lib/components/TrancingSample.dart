import 'dart:math';

import 'package:flutter/material.dart';

class TracingScreen extends StatefulWidget {
  const TracingScreen({super.key});

  @override
  _TracingScreenState createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  List<List<Offset>> allUserPoints = []; // Store all strokes separately
  List<Offset> currentStroke = []; // Store points of the current stroke
  bool stroke1Complete = false;
  bool stroke2Complete = false;
  bool isComplete = false;

  final List<Offset> stroke1Points = [
    const Offset(100, 100),
    const Offset(100, 300)
  ];
  final List<Offset> stroke2Points = [
    const Offset(100, 300),
    const Offset(300, 300)
  ];
  final double tolerance = 20.0;

  bool isStroke1InProgress = false;
  bool isStroke2InProgress = false;

  // Check if the traced point is near the stroke points
  bool _isNearStroke(Offset start, Offset end, Offset point) {
    return (point - start).distance < tolerance ||
        (point - end).distance < tolerance;
  }

  // Detect if strokes are correctly traced
  void _checkStrokeCompletion(Offset point) {
    if (!stroke1Complete && !isStroke1InProgress) {
      if ((point - stroke1Points[0]).distance < tolerance) {
        isStroke1InProgress = true;
      }
    } else if (!stroke1Complete && isStroke1InProgress) {
      if ((point - stroke1Points[1]).distance < tolerance) {
        setState(() {
          stroke1Complete = true;
          isStroke1InProgress = false;
        });
      }
    }

    if (stroke1Complete && !stroke2Complete && !isStroke2InProgress) {
      if ((point - stroke2Points[0]).distance < tolerance) {
        isStroke2InProgress = true;
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
      currentStroke.add(point); // Add points to the current stroke
    });
  }

  void _checkCompletion() {
    if (stroke1Complete && stroke2Complete) {
      setState(() {
        isComplete = true;
      });
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
                allUserPoints.clear();
                currentStroke.clear();
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
        onPanEnd: (details) {
          // When the user lifts their finger, save the current stroke and reset it
          setState(() {
            allUserPoints
                .add(List.from(currentStroke)); // Save the current stroke
            currentStroke.clear(); // Clear current stroke for next one
          });
        },
        child: CustomPaint(
          painter: TracingPainter(
              allUserPoints, currentStroke, stroke1Complete, stroke2Complete),
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
  final List<List<Offset>> allPoints;
  final List<Offset> currentStroke;
  final bool stroke1Complete;
  final bool stroke2Complete;

  TracingPainter(this.allPoints, this.currentStroke, this.stroke1Complete,
      this.stroke2Complete);

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 25.0
      ..style = PaintingStyle.stroke;

    Paint completePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 20.0
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

    // Draw previous user strokes
    for (var stroke in allPoints) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], tracePaint);
      }
    }

    // Draw current stroke in real-time
    if (currentStroke.isNotEmpty) {
      for (int i = 0; i < currentStroke.length - 1; i++) {
        canvas.drawLine(currentStroke[i], currentStroke[i + 1], tracePaint);
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
