import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class PaintInsideSvgApp extends StatelessWidget {
  const PaintInsideSvgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("SVG 내부 색칠하기"),
        ),
        backgroundColor: Colors.white,
        body: const PaintInsideSvg(),
      ),
    );
  }
}

class PaintInsideSvg extends StatefulWidget {
  const PaintInsideSvg({super.key});

  @override
  _PaintInsideSvgState createState() => _PaintInsideSvgState();
}

class _PaintInsideSvgState extends State<PaintInsideSvg> {
  List<Offset> points = [];
  ui.Picture? svgPicture;
  Path boundaryPath = Path();

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  // SVG 파일을 로드하여 Picture로 변환
  Future<void> _loadSvg() async {
    const String svgPath = 'assets/icons/svg/remove-a1.svg';

    // Picture 객체로 변환
    svgPicture = await _loadPicture(svgPath);

    // 예시로 경계 Path 생성 (실제 경계 데이터는 SVG 편집기에서 추출 필요)
    boundaryPath.addOval(Rect.fromCircle(
        center: const Offset(150, 150), radius: 100)); // 임의 경계 예시

    setState(() {});
  }

  // SVG 파일을 Picture로 변환하는 함수
  Future<ui.Picture> _loadPicture(String assetPath) async {
    final DrawableRoot svgRoot = await svg.fromSvgString(
      await DefaultAssetBundle.of(context).loadString(assetPath),
      assetPath,
    );
    return svgRoot.toPicture();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // 경계 안에 있는 점만 추가
          if (boundaryPath.contains(details.localPosition)) {
            points.add(details.localPosition);
          }
        });
      },
      onPanEnd: (details) {
        setState(() {
          points.add(Offset.infinite);
        });
      },
      child: CustomPaint(
        painter: InsideSvgPainter(points, svgPicture, boundaryPath),
        child: Container(),
      ),
    );
  }
}

class InsideSvgPainter extends CustomPainter {
  final List<Offset> points;
  final ui.Picture? svgPicture;
  final Path boundaryPath;

  InsideSvgPainter(this.points, this.svgPicture, this.boundaryPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    if (svgPicture != null) {
      // SVG 경계 그림
      canvas.drawPicture(svgPicture!);
    }

    // 드로잉 점들을 그림
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
