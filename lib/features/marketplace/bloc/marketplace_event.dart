import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadListings extends MarketplaceEvent {
  const LoadListings();
}

class SearchQueryChanged extends MarketplaceEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class CategorySelected extends MarketplaceEvent {
  final String? category;

  const CategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}
