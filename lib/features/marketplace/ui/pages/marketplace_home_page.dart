import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marketplace_bloc.dart';
import '../../bloc/marketplace_event.dart';
import '../../bloc/marketplace_state.dart';
import '../widgets/listing_card.dart';

class MarketplaceHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToSell;

  const MarketplaceHomePage({
    super.key,
    this.onNavigateToSell,
  });

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
  int? _lastKnownCount;
  Timer? _debounce;

  void _clearSearch() {
    _searchController.clear();
    context.read<MarketplaceBloc>().add(const SearchQueryChanged(''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketplaceBloc, MarketplaceState>(
      listenWhen: (previous, current) {
        if (previous.query != current.query) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _searchController.text != current.query) {
              _searchController.text = current.query;
            }
          });
        }
        return false;
      },
      listener: (context, state) {},
      child: BlocConsumer<MarketplaceBloc, MarketplaceState>(
        listenWhen: (previous, current) {
          if (previous.loading && !current.loading) {
            return false;
          }
          final prevCount = previous.allListings.length;
          final currCount = current.allListings.length;
          return prevCount != currCount && _lastKnownCount != null;
        },
        listener: (context, state) {
          if (_lastKnownCount == null) {
            _lastKnownCount = state.allListings.length;
            return;
          }
          
          final prevCount = _lastKnownCount!;
          final currCount = state.allListings.length;
          
          if (currCount > prevCount) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing posted')),
            );
          } else if (currCount < prevCount) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing deleted')),
            );
          }
          
          _lastKnownCount = currCount;
        },
        builder: (context, state) {
          return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Column(
          children: [
            BlocBuilder<MarketplaceBloc, MarketplaceState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 200), () {
                        context.read<MarketplaceBloc>().add(
                              SearchQueryChanged(value),
                            );
                      });
                    },
                  ),
                );
              },
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
                      // "All" is selected when selectedCategory is null
                      // Other categories are selected when selectedCategory matches
                      final isSelected = category == 'All'
                          ? state.selectedCategory == null
                          : state.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            // Always dispatch the event when chip is tapped
                            // "All" dispatches null, others dispatch the category name
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
                  
                  if (_lastKnownCount == null && !state.loading) {
                    _lastKnownCount = state.allListings.length;
                  }

                  if (state.errorMessage != null) {
                    return Center(
                      child: Text('Error: ${state.errorMessage}'),
                    );
                  }

                  if (state.visibleListings.isEmpty ) {
                    if (state.allListings.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No listings yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Be the first to post something.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: widget.onNavigateToSell,
                                child: const Text('Create listing'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Nothing found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.query.trim().isNotEmpty
                                    ? 'No results for "${state.query}"'
                                    : 'Try changing search or category.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton(
                                onPressed: () {
                                  context.read<MarketplaceBloc>().add(
                                        const SearchQueryChanged(''),
                                      );
                                  context.read<MarketplaceBloc>().add(
                                        const CategorySelected(null),
                                      );
                                },
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
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
          );
        },
      ),
    );
  }
}
