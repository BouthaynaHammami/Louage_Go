import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_favorites_repository.dart';
import '../../domain/favorites_data.dart';
import '../../domain/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => HiveFavoritesRepository(),
);

final favoritesProvider = StreamProvider.family<FavoritesData, String>(
  (ref, userId) =>
      ref.watch(favoritesRepositoryProvider).watchFavorites(userId),
);
