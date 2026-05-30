import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'schedule_view.dart';
import 'bookmark_view.dart';
import 'home_view.dart';
import 'profile_view.dart';

class MainWrapper extends StatelessWidget {
  final RxInt _currentIndex = 0.obs;
  final List<Widget> _screens = [
    HomeView(),
    BookmarkView(),
    ScheduleView(),
    ProfileView(),
  ];

  MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _screens[_currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _currentIndex.value,
          onTap: (index) => _currentIndex.value = index,
          selectedItemColor:
              Colors.deepOrangeAccent, // Warna ikon & teks saat dipilih
          unselectedItemColor:
              Colors.grey, // Warna ikon & teks saat tidak dipilih
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Bookmark',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Schedule'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
