import 'package:flutter/material.dart';
import 'package:flutter_tracing_sample/pages/TabletUiScreen.dart';

class MainCategoryScreen extends StatelessWidget {
  final List<Category> categories = [
    Category('블럭 쌓기', Colors.amber, '블럭 쌓기'),
    Category('미술', Colors.purple, '미술'),
    Category('한글', Colors.green, '한글'),
    Category('영어', Colors.blue, '영어'),
    Category('수학', Colors.orange, '수학'),
    Category('코딩', Colors.red, '코딩'),
  ];

  MainCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const Center(
          child: Text('Grow Learning AI 학습',
              style: TextStyle(color: Colors.black, fontSize: 25)),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Chip(
              label: Text('1376 pcs', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFFEA5959),
            ),
          ),
        ],
      ),
      body: Center(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(60, 30, 60, 30),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 35,
            mainAxisSpacing: 20,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TabletUiScreen(
                      title: category.title,
                      themeColor: category.color,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Center(
                  child: Text(
                    category.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Category {
  final String title;
  final Color color;
  final String screen;

  Category(this.title, this.color, this.screen);
}
