import 'package:equatable/equatable.dart';
import '../data/models/listing.dart';

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

class CreateListing extends MarketplaceEvent {
  final Listing listing;

  const CreateListing(this.listing);

  @override
  List<Object?> get props => [listing];
}

class DeleteListing extends MarketplaceEvent {
  final String id;

  const DeleteListing(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearLocalListings extends MarketplaceEvent {
  const ClearLocalListings();
}

class LoadMoreRequested extends MarketplaceEvent {
  const LoadMoreRequested();
}

class ToastConsumed extends MarketplaceEvent {
  const ToastConsumed();
}

class LoadBookmarks extends MarketplaceEvent {
  const LoadBookmarks();
}

class ToggleBookmark extends MarketplaceEvent {
  final String listingId;

  const ToggleBookmark(this.listingId);

  @override
  List<Object?> get props => [listingId];
}
