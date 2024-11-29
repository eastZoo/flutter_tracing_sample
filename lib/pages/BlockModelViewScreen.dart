import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:async';

class BlockModelViewScreen extends StatefulWidget {
  final String title;
  final List<String> modelPaths;

  const BlockModelViewScreen(
      {required this.title, required this.modelPaths, super.key});

  @override
  _BlockModelViewScreenState createState() => _BlockModelViewScreenState();
}

class _BlockModelViewScreenState extends State<BlockModelViewScreen> {
  bool _isStarted = false;
  int _seconds = 0;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _isStarted = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, // 임시 배경색
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _stopTimer();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            '그림과 같이 만들어보세요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: widget.modelPaths.length,
              itemBuilder: (context, index) {
                return const ModelViewer(
                  src: "/assets/models/Duck.gltf",
                  alt: "3D model",
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (!_isStarted)
            ElevatedButton(
              onPressed: _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('START', style: TextStyle(fontSize: 18)),
            )
          else
            Column(
              children: [
                Text(
                  _formatTime(_seconds),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _stopTimer();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('완성!'),
                        content: Text('걸린 시간: ${_formatTime(_seconds)}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                  ),
                  child: const Text('완성', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
