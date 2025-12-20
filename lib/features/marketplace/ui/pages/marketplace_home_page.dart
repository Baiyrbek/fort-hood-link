import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marketplace_bloc.dart';
import '../../bloc/marketplace_event.dart';
import '../../bloc/marketplace_state.dart';
import '../../../../di/marketplace_dependencies.dart';
import '../widgets/listing_card.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Electronics',
    'Furniture',
    'Gaming',
    'Sports',
    'Cars',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketplaceDependencies.createBloc()
        ..add(const LoadListings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  context.read<MarketplaceBloc>().add(
                        SearchQueryChanged(value),
                      );
                },
              ),
            ),
            BlocBuilder<MarketplaceBloc, MarketplaceState>(
              builder: (context, state) {
                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == 'All'
                          ? state.selectedCategory == null
                          : state.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            context.read<MarketplaceBloc>().add(
                                  CategorySelected(
                                    category == 'All' ? null : category,
                                  ),
                                );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.errorMessage != null) {
                    return Center(
                      child: Text('Error: ${state.errorMessage}'),
                    );
                  }

                  if (state.visibleListings.isEmpty) {
                    return const Center(
                      child: Text('No listings found'),
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
                      itemCount: state.visibleListings.length,
                      itemBuilder: (context, index) {
                        return ListingCard(
                          listing: state.visibleListings[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
