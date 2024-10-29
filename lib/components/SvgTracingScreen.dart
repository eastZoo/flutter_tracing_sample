import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgTracingScreen extends StatefulWidget {
  const SvgTracingScreen({super.key});

  @override
  _SvgTracingScreenState createState() => _SvgTracingScreenState();
}

class _SvgTracingScreenState extends State<SvgTracingScreen> {
  List<Offset> currentStroke = [];
  bool path1Complete = false;
  bool path2Complete = false;
  bool isComplete = false;

  // Define the path points for tracing (example points)
  final List<Offset> path1Points = [
    const Offset(100, 100),
    const Offset(100, 300),
  ];

  final List<Offset> path2Points = [
    const Offset(100, 300),
    const Offset(300, 300),
  ];

  final double tolerance = 20.0;

  bool isPath1InProgress = false;
  bool isPath2InProgress = false;

  // Check if the traced point is near the path points
  bool _isNearPath(Offset start, Offset end, Offset point) {
    return (point - start).distance < tolerance ||
        (point - end).distance < tolerance;
  }

  void _checkPathCompletion(Offset point) {
    if (!path1Complete && !isPath1InProgress) {
      if ((point - path1Points[0]).distance < tolerance) {
        isPath1InProgress = true;
      }
    } else if (!path1Complete && isPath1InProgress) {
      if ((point - path1Points[1]).distance < tolerance) {
        setState(() {
          path1Complete = true;
          isPath1InProgress = false;
        });
      }
    }

    if (path1Complete && !path2Complete && !isPath2InProgress) {
      if ((point - path2Points[0]).distance < tolerance) {
        isPath2InProgress = true;
      }
    } else if (path1Complete && isPath2InProgress) {
      if ((point - path2Points[1]).distance < tolerance) {
        setState(() {
          path2Complete = true;
          isPath2InProgress = false;
          _checkCompletion();
        });
      }
    }

    setState(() {
      currentStroke.add(point);
    });
  }

  void _checkCompletion() {
    if (path1Complete && path2Complete) {
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
        content: const Text("모든 경로를 정확히 그렸습니다."),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentStroke.clear();
                path1Complete = false;
                path2Complete = false;
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
      body: GestureDetector(
        onPanUpdate: (details) {
          _checkPathCompletion(details.localPosition);
        },
        onPanEnd: (details) {
          setState(() {
            currentStroke.clear();
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svg/remove-a1.svg',
              color: Colors.grey,
              fit: BoxFit.contain,
            ),
            CustomPaint(
              painter: SvgTracingPainter(
                currentStroke,
                path1Complete,
                path2Complete,
              ),
              child: const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SvgTracingPainter extends CustomPainter {
  final List<Offset> currentStroke;
  final bool path1Complete;
  final bool path2Complete;

  SvgTracingPainter(this.currentStroke, this.path1Complete, this.path2Complete);

  @override
  void paint(Canvas canvas, Size size) {
    Paint completedPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    Paint tracePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    // Draw completed paths
    if (path1Complete) {
      canvas.drawLine(
          const Offset(100, 100), const Offset(100, 300), completedPaint);
    }
    if (path2Complete) {
      canvas.drawLine(
          const Offset(100, 300), const Offset(300, 300), completedPaint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      for (int i = 0; i < currentStroke.length - 1; i++) {
        canvas.drawLine(currentStroke[i], currentStroke[i + 1], tracePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
