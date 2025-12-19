import 'package:equatable/equatable.dart';
import '../data/models/listing.dart';

class MarketplaceState extends Equatable {
  final bool loading;
  final List<Listing> listings;
  final String? errorMessage;

  const MarketplaceState({
    required this.loading,
    required this.listings,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [loading, listings, errorMessage];
}

