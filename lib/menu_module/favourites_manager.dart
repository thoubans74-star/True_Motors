import 'package:flutter/material.dart';
import 'package:true_motors/used_vehicle_module/buy_car.dart';

// ─── Favorites Manager ────────────────────────────────────────────────────────

class FavoritesManager extends ChangeNotifier {
  FavoritesManager._();
  static final FavoritesManager instance = FavoritesManager._();

  // key: unique car identifier (e.g. name+km), value: CarListing
  final Map<String, CarListing> _favorites = {};

  List<CarListing> get favorites => _favorites.values.toList();

  bool isFavorite(CarListing car) => _favorites.containsKey(_key(car));

  void toggle(CarListing car) {
    final k = _key(car);
    if (_favorites.containsKey(k)) {
      _favorites.remove(k);
    } else {
      _favorites[k] = car;
    }
    notifyListeners();
  }

  String _key(CarListing car) => '${car.name}_${car.km}_${car.imagePath}';
}