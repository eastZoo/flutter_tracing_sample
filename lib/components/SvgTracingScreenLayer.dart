import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle을 사용하기 위해 추가
import 'package:flutter_svg/flutter_svg.dart';

class SvgTracingScreenLayer extends StatefulWidget {
  const SvgTracingScreenLayer({super.key});

  @override
  _SvgTracingScreenLayerState createState() => _SvgTracingScreenLayerState();
}

class _SvgTracingScreenLayerState extends State<SvgTracingScreenLayer> {
  List<List<Offset>> allStrokes = []; // 모든 독립적인 선을 저장
  List<Offset> currentStroke = [];
  bool isComplete = false;
  double strokeWidth = 20.0; // 펜의 기본 굵기

  // 클래스 변수로 추가
  Map<int, Color> strokeColors = {};

  Map<int, List<Offset>> pathPoints = {}; // 획 번호별 포인트
  Map<int, int> pathIndices = {}; // 획 번호별 현재 인덱스
  Map<int, bool> pathComplete = {}; // 획 번호별 완료 여부
  List<int> strokeOrder = []; // 획 번호 순서
  int currentPathNumber = 0; // 현재 진행 중인 획 번호

  final double tolerance = 20.0;

  @override
  void initState() {
    super.initState();
    _loadStrokeData();
  }

  // strokes.json 파일 불러오기 및 파싱
  Future<void> _loadStrokeData() async {
    String data = await rootBundle.loadString('assets/strokes.json');
    Map<String, dynamic> jsonData = json.decode(data);

    jsonData.forEach((key, value) {
      int strokeNumber = int.parse(key);
      List<Offset> points = [];
      for (var point in value) {
        points.add(Offset(
          point['x'].toDouble() / 4 + 25,
          point['y'].toDouble() / 4 + 150,
        ));
      }

      print("points: $points");
      pathPoints[strokeNumber] = points;
      pathIndices[strokeNumber] = 0;
      pathComplete[strokeNumber] = false;
      strokeOrder.add(strokeNumber);

      // 랜덤 색상 생성 및 저장
      strokeColors[strokeNumber] = _generateRandomColor();
    });

    // 획 번호 순서대로 정렬
    strokeOrder.sort();

    setState(() {
      currentPathNumber = strokeOrder.first;
    });
  }

// 랜덤 색상 생성 함수 추가
  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  bool _isNearPoint(Offset target, Offset point) {
    return (point - target).distance < tolerance;
  }

  void _checkPathCompletion(Offset point) {
    if (currentPathNumber == 0) return;

    if (!pathComplete[currentPathNumber]!) {
      int currentIndex = pathIndices[currentPathNumber]!;
      List<Offset> points = pathPoints[currentPathNumber]!;

      if (_isNearPoint(points[currentIndex], point)) {
        setState(() {
          pathIndices[currentPathNumber] = currentIndex + 1;
          if (pathIndices[currentPathNumber]! >= points.length) {
            pathComplete[currentPathNumber] = true;
            _moveToNextPath();
          }
        });
      }
    }
  }

  void _moveToNextPath() {
    int currentIndex = strokeOrder.indexOf(currentPathNumber);
    if (currentIndex + 1 < strokeOrder.length) {
      setState(() {
        currentPathNumber = strokeOrder[currentIndex + 1];
      });
    } else {
      // 모든 획 완료
      setState(() {
        isComplete = true;
        currentPathNumber = 0;
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
                pathIndices.updateAll((key, value) => 0);
                pathComplete.updateAll((key, value) => false);
                isComplete = false;
                currentPathNumber = strokeOrder.first;
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
    if (pathPoints.isEmpty) {
      // strokes.json 파일이 로드될 때까지 로딩 화면 표시
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            SvgPicture.network(
              'http://fileserver.eastzoo.xyz/files/tracing-app/f7772945-38a7-4a5b-8a34-4648df41c139.svg',
              color: Colors.black,
              placeholderBuilder: (BuildContext context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            SvgPicture.network(
              'http://fileserver.eastzoo.xyz/files/tracing-app/42c58186-9c0f-44b9-a21c-e808ac0b800e.svg',
              color: isComplete ? Colors.green : Colors.white,
              placeholderBuilder: (BuildContext context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            SvgPicture.network(
              'http://fileserver.eastzoo.xyz/files/tracing-app/2dc2d1b3-8e03-4998-be08-530437267b27.svg',
              color: Colors.black,
              placeholderBuilder: (BuildContext context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            CustomPaint(
              painter: SvgTracingPainter(
                allStrokes,
                currentStroke,
                pathPoints,
                strokeWidth, // 펜의 굵기 전달
                strokeColors, // 추가
              ),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}

class SvgTracingPainter extends CustomPainter {
  final List<List<Offset>> allStrokes;
  final List<Offset> currentStroke;
  final Map<int, List<Offset>> pathPoints;
  final double strokeWidth; // 펜 굵기 변수
  final Map<int, Color> strokeColors; // 추가

  SvgTracingPainter(
    this.allStrokes,
    this.currentStroke,
    this.pathPoints,
    this.strokeWidth,
    this.strokeColors, // 추가
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint()
      ..color = Colors.blue.withOpacity(1)
      ..strokeWidth = strokeWidth // 동적으로 설정된 펜 굵기 사용
      ..strokeCap = StrokeCap.round // 선 끝을 둥글게 설정
      ..style = PaintingStyle.stroke;

    // Paint pointPaint = Paint()
    //   ..color = Colors.red
    //   ..strokeWidth = 10.0
    //   ..style = PaintingStyle.fill;

    // 각 획의 주요 점들을 그리기 (색상 적용)
    pathPoints.forEach((strokeNumber, points) {
      // 해당 획의 색상 가져오기
      Paint pointPaint = Paint()
        ..color = strokeColors[strokeNumber]! // 획별 랜덤 색상 사용
        ..style = PaintingStyle.fill;

      for (final point in points) {
        canvas.drawCircle(point, 5.0, pointPaint);
      }
    });
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
