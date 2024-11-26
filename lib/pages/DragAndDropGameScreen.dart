import 'package:flutter/material.dart';

class DragAndDropGameScreen extends StatefulWidget {
  const DragAndDropGameScreen({super.key});

  @override
  _DragAndDropGameScreenState createState() => _DragAndDropGameScreenState();
}

class _DragAndDropGameScreenState extends State<DragAndDropGameScreen> {
  String targetLetter = '_';
  bool isCorrect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ggq - 언어 학습 게임'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'app',
                  style: TextStyle(fontSize: 32),
                ),
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green : Colors.grey[200],
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isCorrect ? 'e' : targetLetter,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  },
                  onAcceptWithDetails: (details) {
                    String data = details.data;
                    if (data == 'e') {
                      setState(() {
                        isCorrect = true;
                      });
                      _showSuccessDialog('정답입니다!', '축하합니다, 올바른 글자를 선택했습니다.');
                    } else {
                      _showSuccessDialog('틀렸습니다!', '다시 시도해 보세요.');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Draggable<String>(
                  data: 'i',
                  feedback: _buildLetterBox('i', isDragging: true),
                  childWhenDragging: _buildLetterBox(''),
                  child: _buildLetterBox('i'),
                ),
                Draggable<String>(
                  data: 'e',
                  feedback: _buildLetterBox('e', isDragging: true),
                  childWhenDragging: _buildLetterBox(''),
                  child: _buildLetterBox('e'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterBox(String letter, {bool isDragging = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.withOpacity(0.5) : Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
