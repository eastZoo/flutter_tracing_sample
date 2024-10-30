import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgTracingScreenLayer extends StatefulWidget {
  const SvgTracingScreenLayer({super.key});

  @override
  _SvgTracingScreenLayerState createState() => _SvgTracingScreenLayerState();
}

class _SvgTracingScreenLayerState extends State<SvgTracingScreenLayer> {
  List<List<Offset>> allStrokes = []; // 모든 독립적인 선을 저장
  List<Offset> currentStroke = [];
  bool path1Complete = false;
  bool path2Complete = false;
  bool isComplete = false;
  double strokeWidth = 20.0; // 펜의 기본 굵기

  final List<Offset> path1Points = [
    const Offset(310, 220),
    const Offset(170, 175),
    const Offset(50, 325),
    const Offset(170, 450),
    const Offset(310, 410),
  ];

  final List<Offset> path2Points = [
    const Offset(320, 220),
    const Offset(320, 420),
  ];

  final double tolerance = 20.0;
  int path1Index = 0; // 현재 path1에서 도달해야 하는 점 인덱스
  int path2Index = 0; // 현재 path2에서 도달해야 하는 점 인덱스

  bool _isNearPoint(Offset target, Offset point) {
    return (point - target).distance < tolerance;
  }

  void _checkPathCompletion(Offset point) {
    // path1 경로 점 순서대로 체크
    if (!path1Complete) {
      if (_isNearPoint(path1Points[path1Index], point)) {
        setState(() {
          path1Index++;
          if (path1Index >= path1Points.length) {
            path1Complete = true;
            path1Index = 0;
          }
        });
      }
    }

    // path2 경로 점 순서대로 체크
    if (path1Complete && !path2Complete) {
      if (_isNearPoint(path2Points[path2Index], point)) {
        setState(() {
          path2Index++;
          if (path2Index >= path2Points.length) {
            path2Complete = true;
            path2Index = 0;
            _checkCompletion();
          }
        });
      }
    }
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
                allStrokes.clear();
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
          setState(() {
            currentStroke.add(details.localPosition); // 현재 스트로크에 점 추가
          });
        },
        onPanEnd: (details) {
          setState(() {
            allStrokes.add(List.from(currentStroke)); // 현재 스트로크 저장
            currentStroke.clear(); // 새 스트로크 준비
          });
        },
        child: Stack(
          children: [
            SvgPicture.asset(
              'assets/icons/svg/a-out.svg',
              color: Colors.black,
            ),
            SvgPicture.asset(
              'assets/icons/svg/a-in.svg',
              color: isComplete ? Colors.green : Colors.white,
            ),
            SvgPicture.asset(
              'assets/icons/svg/a-guide.svg',
              color: Colors.black,
            ),
            CustomPaint(
              painter: SvgTracingPainter(
                allStrokes,
                currentStroke,
                path1Points,
                path2Points, strokeWidth, // 펜의 굵기 전달
              ),
              child: const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // 굵기 조절 슬라이더
            // Slider(
            //   value: strokeWidth,
            //   min: 1.0,
            //   max: 20.0,
            //   divisions: 19,
            //   label: strokeWidth.round().toString(),
            //   onChanged: (value) {
            //     setState(() {
            //       strokeWidth = value;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class SvgTracingPainter extends CustomPainter {
  final List<List<Offset>> allStrokes;
  final List<Offset> currentStroke;
  final List<Offset> path1Points;
  final List<Offset> path2Points;
  final double strokeWidth; // 펜 굵기 변수

  SvgTracingPainter(
    this.allStrokes,
    this.currentStroke,
    this.path1Points,
    this.path2Points,
    this.strokeWidth,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint()
      ..color = Colors.blue.withOpacity(1)
      ..strokeWidth = strokeWidth // 동적으로 설정된 펜 굵기 사용
      ..strokeCap = StrokeCap.round // 선 끝을 둥글게 설정
      ..style = PaintingStyle.fill;

    Paint point1Paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;

    Paint point2Paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;

    // 각 path의 주요 점들을 빨간 점으로 그리기
    for (final point in path1Points) {
      canvas.drawCircle(point, 5.0, point1Paint);
    }
    for (final point in path2Points) {
      canvas.drawCircle(point, 5.0, point2Paint);
    }

    // 모든 이전 스트로크 그리기
    for (var stroke in allStrokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], strokePaint);
      }
    }

    // 현재 스트로크를 실시간으로 그리기
    if (currentStroke.isNotEmpty) {
      for (int i = 0; i < currentStroke.length - 1; i++) {
        canvas.drawLine(currentStroke[i], currentStroke[i + 1], strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
