import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome 사용을 위해 추가
import 'package:flutter_tracing_sample/pages/PixelColoringGameScreen.dart';
import 'package:flutter_tracing_sample/pages/SvgTracingScreen.dart';
import 'package:flutter_tracing_sample/pages/DragAndDropGameScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Alphabet Tracing"),
        ),
        backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
        body: const PixelColoringGameScreen(),
      ),
    );
  }
}
