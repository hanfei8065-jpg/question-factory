import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'solve_page.dart';

class HeroPage extends StatefulWidget {
  const HeroPage({Key? key}) : super(key: key);

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CameraPage(),
    SolvePage(),
    // 题库页、AI名师页可后续补充
    Center(child: Text('题库页（待开发）')),
    Center(child: Text('AI名师页（待开发）')),
    Center(child: Text('我的页（待开发）')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '拍题'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '做题'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '题库'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'AI名师'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
