import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/marketplace_dependencies.dart';
import '../../bloc/marketplace_event.dart';
import 'marketplace_home_page.dart';
import 'sell_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void switchToSellTab() {
    setState(() {
      _currentIndex = 1;
    });
  }

  List<Widget> get _pages => [
        MarketplaceHomePage(
          onNavigateToSell: switchToSellTab,
        ),
        SellPage(
          onPosted: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        const ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceDependencies.createBloc()
        ..add(const LoadListings()),
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
            icon: Icon(Icons.sell),
            label: 'Sell',
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
