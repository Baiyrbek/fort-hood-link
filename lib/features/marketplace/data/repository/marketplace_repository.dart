import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing.dart';

class MarketplaceRepository {
  static const String _key = 'marketplace_listings_v1';

  List<Listing> _getSeedListings() {
    return [
      Listing(
        id: '1',
        title: 'Gaming Laptop',
        description: 'High performance gaming laptop, barely used',
        price: 1200,
        category: 'Electronics',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=1'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ownerId: 'seed',
      ),
      Listing(
        id: '2',
        title: 'Coffee Table',
        description: 'Wooden coffee table in good condition',
        price: 75,
        category: 'Furniture',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=2'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ownerId: 'seed',
      ),
      Listing(
        id: '3',
        title: 'Bicycle',
        description: 'Mountain bike, well maintained',
        price: 250,
        category: 'Sports',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=3'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ownerId: 'seed',
      ),
      Listing(
        id: '4',
        title: 'iPhone 13',
        description: 'Unlocked iPhone 13, excellent condition',
        price: 600,
        category: 'Electronics',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=4'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ownerId: 'seed',
      ),
      Listing(
        id: '5',
        title: 'Dining Set',
        description: 'Complete dining table with 4 chairs',
        price: 300,
        category: 'Furniture',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=5'],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ownerId: 'seed',
      ),
      Listing(
        id: '6',
        title: 'Guitar',
        description: 'Acoustic guitar, perfect for beginners',
        price: 150,
        category: 'Music',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=6'],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        ownerId: 'seed',
      ),
      Listing(
        id: '7',
        title: 'TV Stand',
        description: 'Modern TV stand with storage',
        price: 120,
        category: 'Furniture',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=7'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ownerId: 'seed',
      ),
      Listing(
        id: '8',
        title: 'Camera',
        description: 'DSLR camera with lens included',
        price: 450,
        category: 'Electronics',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=8'],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ownerId: 'seed',
      ),
      Listing(
        id: '9',
        title: 'Workout Bench',
        description: 'Adjustable workout bench',
        price: 80,
        category: 'Sports',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=9'],
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        ownerId: 'seed',
      ),
      Listing(
        id: '10',
        title: 'Bookshelf',
        description: 'Tall wooden bookshelf',
        price: 90,
        category: 'Furniture',
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=10'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ownerId: 'seed',
      ),
    ];
  }

  Future<List<Listing>> fetchListings() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      // First run: use seed listings, save them, and return
      final seedListings = _getSeedListings();
      await saveListings(seedListings);
      return seedListings;
    }

    // Load from SharedPreferences
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((json) => Listing.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> saveListings(List<Listing> listings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = listings.map((listing) => listing.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_key, jsonString);
  }
}
