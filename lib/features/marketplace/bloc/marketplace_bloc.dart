import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/marketplace_repository.dart';
import '../data/models/listing.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository repository;
  static const int _pageSize = 4;

  MarketplaceBloc({required this.repository})
      : super(const MarketplaceState(
          loading: false,
          allListings: [],
          visibleListings: [],
        )) {
    on<LoadListings>(_onLoadListings);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelected>(_onCategorySelected);
    on<CreateListing>(_onCreateListing);
    on<DeleteListing>(_onDeleteListing);
    on<ClearLocalListings>(_onClearLocalListings);
    on<LoadMoreRequested>(_onLoadMoreRequested);
    on<ToastConsumed>(_onToastConsumed);
  }

  Future<void> _onLoadListings(
    LoadListings event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      allListings: [],
      visibleListings: [],
    ));

    try {
      final listings = await repository.fetchListings();
      final filteredListings = _filterListings(
        listings,
        state.query,
        state.selectedCategory,
      );
      emit(state.copyWith(
        loading: false,
        allListings: listings,
        visibleListings: filteredListings,
        loadedCount: _pageSize,
        hasReachedEnd: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        allListings: [],
        visibleListings: [],
        errorMessage: e.toString(),
        loadedCount: _pageSize,
        hasReachedEnd: false,
        isLoadingMore: false,
      ));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MarketplaceState> emit,
  ) {
    final filteredListings = _filterListings(
      state.allListings,
      event.query,
      state.selectedCategory,
    );
    emit(state.copyWith(
      query: event.query,
      visibleListings: filteredListings,
      loadedCount: _pageSize,
      hasReachedEnd: false,
      isLoadingMore: false,
    ));
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<MarketplaceState> emit,
  ) {
    final filteredListings = _filterListings(
      state.allListings,
      state.query,
      event.category,
    );
    emit(state.copyWith(
      selectedCategory: event.category,
      visibleListings: filteredListings,
      loadedCount: _pageSize,
      hasReachedEnd: false,
      isLoadingMore: false,
    ));
  }

  Future<void> _onCreateListing(
    CreateListing event,
    Emitter<MarketplaceState> emit,
  ) async {
    final updatedListings = [event.listing, ...state.allListings];
    // Reset filters to show all listings, ensuring new listing is visible
    final filteredListings = _filterListings(
      updatedListings,
      '',
      null,
    );
    emit(state.copyWith(
      allListings: updatedListings,
      visibleListings: filteredListings,
      query: '',
      selectedCategory: null,
      loadedCount: _pageSize,
      hasReachedEnd: false,
      isLoadingMore: false,
      toast: 'posted',
    ));
    // Persist to SharedPreferences
    await repository.saveListings(updatedListings);
  }

  Future<void> _onDeleteListing(
    DeleteListing event,
    Emitter<MarketplaceState> emit,
  ) async {
    final updatedListings = state.allListings
        .where((listing) => listing.id != event.id)
        .toList();
    final filteredListings = _filterListings(
      updatedListings,
      state.query,
      state.selectedCategory,
    );
    emit(state.copyWith(
      allListings: updatedListings,
      visibleListings: filteredListings,
      loadedCount: _pageSize,
      hasReachedEnd: false,
      isLoadingMore: false,
      toast: 'deleted',
    ));
    // Persist to SharedPreferences
    await repository.saveListings(updatedListings);
  }

  Future<void> _onClearLocalListings(
    ClearLocalListings event,
    Emitter<MarketplaceState> emit,
  ) async {
    await repository.clearListings();
    // Reload listings (will fetch seed listings after clear)
    final listings = await repository.fetchListings();
    final filteredListings = _filterListings(
      listings,
      state.query,
      state.selectedCategory,
    );
    emit(state.copyWith(
      allListings: listings,
      visibleListings: filteredListings,
      loadedCount: _pageSize,
      hasReachedEnd: false,
      isLoadingMore: false,
    ));
  }

  Future<void> _onLoadMoreRequested(
    LoadMoreRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    if (state.isLoadingMore) {
      return;
    }

    final filtered = _filterListings(
      state.allListings,
      state.query,
      state.selectedCategory,
    );

    emit(state.copyWith(isLoadingMore: true));

    await Future.delayed(const Duration(milliseconds: 500));

    List<Listing> updatedAllListings = state.allListings;
    List<Listing> updatedVisibleListings = filtered;

    if (state.loadedCount >= filtered.length) {
      final oldestCreatedAt = updatedAllListings.isEmpty
          ? DateTime.now()
          : updatedAllListings.map((l) => l.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
      final newListings = _generateMoreListings(_pageSize, oldestCreatedAt);
      updatedAllListings = [...updatedAllListings, ...newListings];
      updatedVisibleListings = _filterListings(
        updatedAllListings,
        state.query,
        state.selectedCategory,
      );
    }

    final nextCount = min(
      state.loadedCount + _pageSize,
      updatedVisibleListings.length,
    );

    emit(state.copyWith(
      allListings: updatedAllListings,
      visibleListings: updatedVisibleListings,
      loadedCount: nextCount,
      isLoadingMore: false,
      hasReachedEnd: false,
    ));
  }

  List<Listing> _generateMoreListings(int count, DateTime startFrom) {
    final random = Random();
    final categories = ['Electronics', 'Furniture', 'Gaming', 'Sports', 'Cars'];
    
    return List.generate(count, (index) {
      final id = (startFrom.microsecondsSinceEpoch - index).toString();
      final category = categories[random.nextInt(categories.length)];
      
      return Listing(
        id: id,
        title: 'Item #$id',
        description: 'Generated item in $category category',
        price: 50 + random.nextInt(2000),
        category: category,
        location: 'Fort Hood, TX',
        images: ['https://picsum.photos/400?random=$id'],
        createdAt: startFrom.subtract(Duration(minutes: index + 1)),
        ownerId: 'seed',
      );
    });
  }

  void _onToastConsumed(
    ToastConsumed event,
    Emitter<MarketplaceState> emit,
  ) {
    emit(state.copyWith(toast: null));
  }

  List<Listing> _filterListings(
    List<Listing> listings,
    String query,
    String? category,
  ) {
    var filtered = listings;

    // Filter by category
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((listing) => listing.category == category).toList();
    }

    // Filter by query (case-insensitive search in title and description)
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((listing) {
        final titleMatch = listing.title.toLowerCase().contains(lowerQuery);
        final descriptionMatch = listing.description.toLowerCase().contains(lowerQuery);
        return titleMatch || descriptionMatch;
      }).toList();
    }

    return filtered;
  }
}
