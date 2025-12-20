import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/marketplace_repository.dart';
import '../data/models/listing.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository repository;

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
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        allListings: [],
        visibleListings: [],
        errorMessage: e.toString(),
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
    ));
    // Persist to SharedPreferences
    await repository.saveListings(updatedListings);
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
