import 'package:flutter/material.dart';

class TabletUiScreen extends StatefulWidget {
  const TabletUiScreen({super.key});

  @override
  _TabletUiScreenState createState() => _TabletUiScreenState();
}

class _TabletUiScreenState extends State<TabletUiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final Map<int, List<String>> categoryItems = {
    0: List.generate(30, (index) => '기초 학습 아이템 ${index + 1}'),
    1: List.generate(30, (index) => '블럭 칠하기 아이템 ${index + 1}'),
    2: List.generate(30, (index) => '동물 아이템 ${index + 1}'),
    3: List.generate(30, (index) => '수상동물 아이템 ${index + 1}'),
    4: List.generate(30, (index) => '조류 아이템 ${index + 1}'),
    5: List.generate(30, (index) => '과일/야채 아이템 ${index + 1}'),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF775ec2), // 배경색 설정
      appBar: AppBar(
        backgroundColor: const Color(0xFF775ec2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          '미술',
          style: TextStyle(color: Colors.white, fontSize: 24),
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
            color: const Color(0xFFb9acd8),
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
                tabs: [
                  Tab(
                    icon: Column(
                      children: [
                        Image.asset('assets/images/giraffe.jpg', height: 20),
                        const SizedBox(height: 4),
                        const Text('기초 학습'),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Column(
                      children: [
                        Image.asset('assets/images/giraffe.jpg', height: 20),
                        const SizedBox(height: 4),
                        const Text('블럭 칠하기'),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Column(
                      children: [
                        Image.asset('assets/images/giraffe.jpg', height: 20),
                        const SizedBox(height: 4),
                        const Text('동물'),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Column(
                      children: [
                        Image.asset('assets/images/giraffe.jpg', height: 20),
                        const SizedBox(height: 4),
                        const Text('수상동물'),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Column(
                      children: [
                        Image.asset('assets/images/giraffe.jpg', height: 20),
                        const SizedBox(height: 4),
                        const Text('조류'),
                      ],
                    ),
                  ),
                  Tab(
                    icon: Column(
                      children: [
                        Image.asset('assets/images/giraffe.jpg', height: 20),
                        const SizedBox(height: 4),
                        const Text('과일/야채'),
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
                  color: const Color(0xFF907dcd),
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
                    return GridItem(
                        title: categoryItems[_selectedTabIndex]![index],
                        index: index + 1);
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
                radius: 12,
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
