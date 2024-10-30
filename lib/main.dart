import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tracing_sample/components/PaintInsideSvg.dart';
import 'package:flutter_tracing_sample/components/SvgTracingScreen.dart';
import 'package:flutter_tracing_sample/components/SvgTracingScreenLayer.dart';

void main() => runApp(const TracingApp());

class TracingApp extends StatelessWidget {
  const TracingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Alphabet Tracing"),
        ),
        backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
        body: const SvgTracingScreenLayer(),
      ),
    );
  }
}
