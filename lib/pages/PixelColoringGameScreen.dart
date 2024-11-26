import 'package:flutter/material.dart';

class PixelColoringGameScreen extends StatefulWidget {
  const PixelColoringGameScreen({super.key});

  @override
  _PixelColoringGameScreenState createState() =>
      _PixelColoringGameScreenState();
}

enum ToolType { pen, bucket, eraser }

class _PixelColoringGameScreenState extends State<PixelColoringGameScreen> {
  final int rows = 10;
  final int columns = 10;
  final Color defaultColor = Colors.white;
  Color currentColor = Colors.purple;
  ToolType selectedTool = ToolType.pen;
  List<List<Color>> pixelColors = [];

  @override
  void initState() {
    super.initState();
    pixelColors = List.generate(
        rows, (index) => List.generate(columns, (index) => defaultColor));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: List.generate(rows, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(columns, (col) {
                          return GestureDetector(
                            onPanUpdate: selectedTool == ToolType.pen
                                ? (details) => _colorPixel(row, col)
                                : null,
                            onTap: () => _applyTool(row, col),
                            child: Container(
                              width: 30,
                              height: 30,
                              margin: const EdgeInsets.all(1.0),
                              color: pixelColors[row][col],
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                _buildToolPalette(),
                const SizedBox(height: 20),
                _buildColorPalette(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkIfCompleted,
                  child: const Text('Submit'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolPalette() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _toolChoiceButton(Icons.edit, ToolType.pen),
        _toolChoiceButton(Icons.format_color_fill, ToolType.bucket),
        _toolChoiceButton(Icons.earbuds_battery, ToolType.eraser),
      ],
    );
  }

  Widget _toolChoiceButton(IconData icon, ToolType toolType) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTool = toolType;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: selectedTool == toolType ? Colors.grey : Colors.white,
          border: Border.all(color: Colors.black),
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _colorChoiceButton(Colors.red),
        _colorChoiceButton(Colors.orange),
        _colorChoiceButton(Colors.yellow),
        _colorChoiceButton(Colors.green),
        _colorChoiceButton(Colors.blue),
        _colorChoiceButton(Colors.purple),
        _colorChoiceButton(Colors.black),
        _colorChoiceButton(Colors.white),
      ],
    );
  }

  Widget _colorChoiceButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _applyTool(int row, int col) {
    setState(() {
      switch (selectedTool) {
        case ToolType.pen:
          pixelColors[row][col] = currentColor;
          break;
        case ToolType.bucket:
          _fill(row, col, pixelColors[row][col], currentColor);
          break;
        case ToolType.eraser:
          pixelColors[row][col] = defaultColor;
          break;
      }
    });
  }

  void _colorPixel(int row, int col) {
    if (selectedTool == ToolType.pen) {
      setState(() {
        pixelColors[row][col] = currentColor;
      });
    }
  }

  void _fill(int row, int col, Color targetColor, Color replacementColor) {
    if (targetColor == replacementColor ||
        pixelColors[row][col] != targetColor) {
      return;
    }

    pixelColors[row][col] = replacementColor;
    if (row > 0) _fill(row - 1, col, targetColor, replacementColor);
    if (row < rows - 1) _fill(row + 1, col, targetColor, replacementColor);
    if (col > 0) _fill(row, col - 1, targetColor, replacementColor);
    if (col < columns - 1) _fill(row, col + 1, targetColor, replacementColor);
  }

  void _checkIfCompleted() {
    bool allColored =
        pixelColors.every((row) => row.every((color) => color != defaultColor));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(allColored ? '완료되었습니다!' : '미완성입니다!'),
          content: Text(allColored
              ? '축하합니다, 모든 칸을 색칠했습니다.'
              : '아직 색칠이 안 된 칸이 있습니다. 계속 진행해 보세요.'),
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
