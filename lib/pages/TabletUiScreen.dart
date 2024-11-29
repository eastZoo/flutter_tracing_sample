import 'package:flutter/material.dart';
import 'package:flutter_tracing_sample/pages/BlockModelViewScreen.dart';

class TabletUiScreen extends StatefulWidget {
  final String title;
  final Color themeColor;

  const TabletUiScreen(
      {required this.title, required this.themeColor, super.key});

  @override
  _TabletUiScreenState createState() => _TabletUiScreenState();
}

class _TabletUiScreenState extends State<TabletUiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final Map<int, List<String>> categoryItems = {
    0: List.generate(15, (index) => '기초 학습 아이템 ${index + 1}'),
    1: List.generate(15, (index) => '블럭 칠하기 아이템 ${index + 1}'),
    2: List.generate(15, (index) => '동물 아이템 ${index + 1}'),
    3: List.generate(15, (index) => '수상동물 아이템 ${index + 1}'),
    4: List.generate(15, (index) => '조류 아이템 ${index + 1}'),
    5: List.generate(15, (index) => '과일/야채 아이템 ${index + 1}'),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeColor, // 테마 색상 설정
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Chip(
              label: Text('1375 pcs', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFFEA5959),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: widget.themeColor.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            alignment: Alignment.center,
            child: Center(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                tabs: const [
                  Tab(
                    child: Column(
                      children: [
                        Text('STEP 01',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('한글 배우기'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: [
                        Text('STEP 02',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('단어'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: [
                        Text('STEP 03',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('간단한 문장 만들기'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      children: [
                        Text('STEP 04',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('책 읽기'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.themeColor.withGreen(220),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: categoryItems[_selectedTabIndex]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlockModelViewScreen(
                              title: categoryItems[_selectedTabIndex]![index],
                              modelPaths: const [
                                // 예시 gltf 파일 경로들
                                'https://example.com/model1.gltf',
                                'https://example.com/model2.gltf',
                              ],
                            ),
                          ),
                        );
                      },
                      child: GridItem(
                          title: categoryItems[_selectedTabIndex]![index],
                          index: index + 1),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final int index;
  final String title;

  const GridItem({super.key, required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Icon(
                  Icons.image, // 임시 아이콘 (실제 이미지로 대체 가능)
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 15,
                child: Text(
                  index < 10 ? '0$index' : '$index',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
