import 'package:equatable/equatable.dart';
import '../data/models/listing.dart';

class MarketplaceState extends Equatable {
  final bool loading;
  final List<Listing> allListings;
  final List<Listing> visibleListings;
  final String query;
  final String? selectedCategory;
  final String? errorMessage;

  const MarketplaceState({
    required this.loading,
    required this.allListings,
    required this.visibleListings,
    this.query = '',
    this.selectedCategory,
    this.errorMessage,
  });

  static const Object _unset = Object();

  MarketplaceState copyWith({
    bool? loading,
    List<Listing>? allListings,
    List<Listing>? visibleListings,
    String? query,
    Object? selectedCategory = _unset,
    String? errorMessage,
  }) {
    return MarketplaceState(
      loading: loading ?? this.loading,
      allListings: allListings ?? this.allListings,
      visibleListings: visibleListings ?? this.visibleListings,
      query: query ?? this.query,
      selectedCategory: selectedCategory == _unset
          ? this.selectedCategory
          : selectedCategory as String?,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        allListings,
        visibleListings,
        query,
        selectedCategory,
        errorMessage,
      ];
}
