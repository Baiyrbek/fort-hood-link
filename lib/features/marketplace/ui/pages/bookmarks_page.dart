import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marketplace_bloc.dart';
import '../../bloc/marketplace_state.dart';
import '../widgets/listing_card.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
      ),
      body: BlocBuilder<MarketplaceBloc, MarketplaceState>(
        builder: (context, state) {
          final bookmarkedListings = state.allListings
              .where((listing) => state.bookmarkedIds.contains(listing.id))
              .toList();

          if (bookmarkedListings.isEmpty) {
            return const Center(
              child: Text('No saved listings yet'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: bookmarkedListings.length,
              itemBuilder: (context, index) {
                return ListingCard(
                  key: ValueKey(bookmarkedListings[index].id),
                  listing: bookmarkedListings[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

