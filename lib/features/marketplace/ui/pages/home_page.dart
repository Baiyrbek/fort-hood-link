import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/marketplace_dependencies.dart';
import '../../bloc/marketplace_event.dart';
import 'marketplace_home_page.dart';
import 'sell_page.dart';
import 'categories_page.dart';
import 'bookmarks_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _navigateToSell() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellPage(
          onPosted: () {
            Navigator.pop(context);
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
      ),
    );
  }

  List<Widget> get _pages => [
        MarketplaceHomePage(
          onNavigateToSell: _navigateToSell,
        ),
        CategoriesPage(
          onCategorySelected: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        const BookmarksPage(),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceDependencies.createBloc()
        ..add(const LoadListings()),
      child: Scaffold(
        body: _pages[_currentIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToSell,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
      ),
    );
  }
}
