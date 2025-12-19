import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/marketplace_repository.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository repository;

  MarketplaceBloc({required this.repository})
      : super(const MarketplaceState(
          loading: false,
          listings: [],
        )) {
    on<LoadListings>(_onLoadListings);
  }

  Future<void> _onLoadListings(
    LoadListings event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceState(
      loading: true,
      listings: [],
    ));

    try {
      final listings = await repository.fetchListings();
      emit(MarketplaceState(
        loading: false,
        listings: listings,
      ));
    } catch (e) {
      emit(MarketplaceState(
        loading: false,
        listings: [],
        errorMessage: e.toString(),
      ));
    }
  }
}

