import '../features/marketplace/bloc/marketplace_bloc.dart';
import '../features/marketplace/data/repository/marketplace_repository.dart';

class MarketplaceDependencies {
  static MarketplaceRepository createRepository() {
    return MarketplaceRepository();
  }

  static MarketplaceBloc createBloc() {
    return MarketplaceBloc(
      repository: createRepository(),
    );
  }
}

