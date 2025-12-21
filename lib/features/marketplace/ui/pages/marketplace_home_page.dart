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
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = [
    'All',
    'Electronics',
    'Furniture',
    'Gaming',
    'Sports',
    'Cars',
  ];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) {
      return;
    }

    const threshold = 200.0;
    if (pos.pixels >= pos.maxScrollExtent - threshold) {
      final bloc = context.read<MarketplaceBloc>();
      if (!bloc.state.isLoadingMore && !bloc.state.hasReachedEnd) {
        bloc.add(const LoadMoreRequested());
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<MarketplaceBloc>().add(const SearchQueryChanged(''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
        listenWhen: (previous, current) => previous.toast != current.toast && current.toast != null,
        listener: (context, state) {
          if (state.toast == 'posted') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing posted')),
            );
            context.read<MarketplaceBloc>().add(const ToastConsumed());
          } else if (state.toast == 'deleted') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing deleted')),
            );
            context.read<MarketplaceBloc>().add(const ToastConsumed());
          }
        },
        builder: (context, state) {
          return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Stack(
          children: [
            Column(
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
                  Future<void> _onRefresh() async {
                    context.read<MarketplaceBloc>().add(const LoadListings());
                    await context.read<MarketplaceBloc>().stream.firstWhere(
                      (s) => !s.loading,
                    );
                  }

                  if (state.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  Widget content;
                  
                  if (state.errorMessage != null) {
                    content = Center(
                      child: Text('Error: ${state.errorMessage}'),
                    );
                  } else if (state.visibleListings.isEmpty) {
                    if (state.allListings.isEmpty) {
                      content = Center(
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
                      content = Center(
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
                    content = SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: content,
                      ),
                    );
                  } else {
                    final pagedListings = state.visibleListings
                        .take(state.loadedCount)
                        .toList();
                    final itemCount = pagedListings.length +
                        (state.isLoadingMore ? 1 : 0);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      final bloc = context.read<MarketplaceBloc>();
                      if (!_scrollController.hasClients) return;
                      if (_scrollController.position.maxScrollExtent != 0) return;
                      if (state.visibleListings.length > state.loadedCount &&
                          !state.isLoadingMore &&
                          !state.hasReachedEnd) {
                        bloc.add(const LoadMoreRequested());
                      }
                    });

                    content = Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          final showFooter = state.isLoadingMore;
                          if (showFooter && index == pagedListings.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return ListingCard(
                            listing: pagedListings[index],
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: content,
                  );
                },
              ),
            ),
          ],
        ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
                  builder: (context, state) {
                    return Text(
                      'loaded: ${state.loadedCount} / visible: ${state.visibleListings.length}\n'
                      'loadingMore: ${state.isLoadingMore}\n'
                      'end: ${state.hasReachedEnd}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    );
                  },
                ),
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
