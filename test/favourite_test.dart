import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokepoke/core/services/favourite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FavouriteService.init();
  });

  group('FavouriteService', () {
    test('toggling favourite updates state and persistence', () async {
      expect(FavouriteService.isFavourite(25), isFalse);

      final added = await FavouriteService.toggleFavourite(25);
      expect(added, isTrue);
      expect(FavouriteService.isFavourite(25), isTrue);
      expect(FavouriteService.favouritesNotifier.value.contains(25), isTrue);

      final removed = await FavouriteService.toggleFavourite(25);
      expect(removed, isFalse);
      expect(FavouriteService.isFavourite(25), isFalse);
      expect(FavouriteService.favouritesNotifier.value.contains(25), isFalse);
    });

    test('loads previously stored favourites on init', () async {
      SharedPreferences.setMockInitialValues({
        'favourite_pokemon_ids_v1': ['1', '4', '7'],
      });

      await FavouriteService.init();
      expect(FavouriteService.isFavourite(1), isTrue);
      expect(FavouriteService.isFavourite(4), isTrue);
      expect(FavouriteService.isFavourite(7), isTrue);
      expect(FavouriteService.isFavourite(25), isFalse);
      expect(FavouriteService.favouritesNotifier.value.length, equals(3));
    });
  });
}
