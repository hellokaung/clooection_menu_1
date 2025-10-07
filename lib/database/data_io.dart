import 'package:hive_flutter/hive_flutter.dart';
import '../models/raw_data.dart';
import '../models/cart_item.dart';
import '../service/api_service.dart';

class DataIO {
  // Use 'settings' box for flags like 'needsRestart'
  static late Box settingsBox;
  static late Box<Map> cartBox;
  static List<CartItem> _cartItemsCache = [];
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    settingsBox = await Hive.openBox('settings'); // Initialize settings box
    cartBox = await Hive.openBox<Map>('cartBox');
    await _updateCartItemsCache();
    cartBox.watch().listen((event) {
      _updateCartItemsCache();
    });
    _isInitialized = true;
  }

  // --- Restart Logic Methods ---

  /// Sets a flag indicating the app needs to be restarted (e.g., after new data download).
  static Future<void> setNeedsRestart() async {
    if (!_isInitialized) await init();
    await settingsBox.put('needsRestart', true);
  }

  /// Checks if the app needs a restart.
  static bool getNeedsRestart() {
    if (!_isInitialized) return false;
    return settingsBox.get('needsRestart', defaultValue: false) as bool;
  }

  /// Clears the restart flag after the user has acknowledged or performed the restart.
  static Future<void> clearNeedsRestart() async {
    if (!_isInitialized) await init();
    await settingsBox.put('needsRestart', false);
  }

  // --- Data Saving/Fetching Methods ---

  static Future<void> saveCategories(List<Category> categories) async {
    var box = await Hive.openBox('categoriesBox');
    await box.put('categories', categories.map((c) => c.toJson()).toList());
  }

  static Future<List<Category>> fetchFoodCategories() async {
    var box = await Hive.openBox('categoriesBox');
    final list = box.get('categories', defaultValue: []) as List;
    return list
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.food)
        .toList();
  }

  static Future<List<Category>> fetchDrinkCategories() async {
    var box = await Hive.openBox('categoriesBox');
    final list = box.get('categories', defaultValue: []) as List;
    return list
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => !c.food)
        .toList();
  }

  static Future<void> saveLists(List<ListElement> lists) async {
    var box = await Hive.openBox('listsBox');
    await box.put('lists', lists.map((l) => l.toJson()).toList());
  }

  static Future<List<ListElement>> fetchListsByCategory(
    String categoryId,
  ) async {
    var box = await Hive.openBox('listsBox');
    final list = box.get('lists', defaultValue: []) as List;
    return list
        .map((e) => ListElement.fromJson(Map<String, dynamic>.from(e)))
        .where((l) => l.category == categoryId)
        .toList();
  }

  static Future<void> saveAddOns(List<AddOn> addOns) async {
    var box = await Hive.openBox('addOnsBox');
    await box.put('addOns', addOns.map((a) => a.toJson()).toList());
  }

  static Future<List<AddOn>> fetchAddOns(String? type) async {
    var box = await Hive.openBox('addOnsBox');
    final list = box.get('addOns', defaultValue: []) as List;
    return list
        .map((e) => AddOn.fromJson(Map<String, dynamic>.from(e)))
        .where((l) => type == null || l.type == type)
        .toList();
  }

  static Future<void> saveDataFromApi(RawData data) async {
    await saveCategories(data.categories);
    await saveLists(data.lists);
    await saveAddOns(data.addOn);
    // CRITICAL FIX: Set the restart flag after saving new core data
    await setNeedsRestart();
  }

  static Future<void> fetchDataAndSave(ApiService apiService) async {
    final rawdata = await apiService.getRawData();
    if (rawdata == null) {
      throw Exception('API returned null data');
    }
    await saveDataFromApi(rawdata);
  }

  static Future<List<ListElement>> searchLists({
    String? type,
    String? query,
  }) async {
    var box = await Hive.openBox('listsBox');
    final list = box.get('lists', defaultValue: []) as List;
    final lowerQuery = query?.toLowerCase() ?? '';
    return list
        .map((e) => ListElement.fromJson(Map<String, dynamic>.from(e)))
        .where((l) {
          final matchesType = type == null || l.types == type;
          final matchesQuery =
              lowerQuery.isEmpty ||
              l.title.toLowerCase().contains(lowerQuery) ||
              l.description.any(
                (desc) => desc.toLowerCase().contains(lowerQuery),
              ) ||
              l.ingredients.any(
                (ing) => ing.toLowerCase().contains(lowerQuery),
              );
          return matchesType && matchesQuery;
        })
        .toList();
  }

  static Future<List<ListElement>> fetchFavLists() async {
    var favBox = await Hive.openBox('favBox');
    var listBox = await Hive.openBox('listsBox');
    final favs = favBox.get('favs', defaultValue: <String>[]) as List;
    final list = listBox.get('lists', defaultValue: []) as List;
    final allLists = list
        .map((e) => ListElement.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return allLists.where((l) => favs.contains(l.id)).toList();
  }

  static Future<void> addFav(String listId) async {
    var box = await Hive.openBox('favBox');
    final favs = box.get('favs', defaultValue: <String>[]) as List;
    if (!favs.contains(listId)) {
      favs.add(listId);
      await box.put('favs', favs);
    }
  }

  static Future<void> removeFav(String listId) async {
    var box = await Hive.openBox('favBox');
    final favs = box.get('favs', defaultValue: <String>[]) as List;
    favs.remove(listId);
    await box.put('favs', favs);
  }

  static Future<bool> checkFav(String listId) async {
    var box = await Hive.openBox('favBox');
    final favs = box.get('favs', defaultValue: <String>[]) as List;
    return favs.contains(listId);
  }

  static Future<void> _updateCartItemsCache() async {
    if (!_isInitialized) {
      init();
    }
    _cartItemsCache = cartBox.values
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        .toSet() // Remove duplicates based on object equality
        .toList();
  }

  // ... (Other methods like saveCategories, fetchFoodCategories, etc., remain unchanged)

  static Future<void> addToCart(CartItem item) async {
    if (!_isInitialized) {
      init();
    }
    final key = '${item.id}${item.note}';
    final existingItem = _cartItemsCache.firstWhere(
      (cartItem) => cartItem.id == item.id && cartItem.note == item.note,
      orElse: () => CartItem(
        id: '',
        thumbnail: '',
        title: '',
        addOns: [],
        note: '',
        totalPrice: 0,
        times: 0,
      ),
    );
    if (existingItem.id.isNotEmpty) {
      final updatedItem = CartItem(
        id: existingItem.id,
        thumbnail: existingItem.thumbnail,
        title: existingItem.title,
        addOns: existingItem.addOns,
        note: existingItem.note,
        totalPrice: existingItem.totalPrice,
        times: existingItem.times + 1,
      );
      await cartBox.put(key, updatedItem.toJson());
      _cartItemsCache = _cartItemsCache
          .map((e) => e.id == item.id && e.note == item.note ? updatedItem : e)
          .toList();
    } else {
      await cartBox.put(key, item.toJson());
      _cartItemsCache.add(item);
    }
    await _updateCartItemsCache(); // Ensure cache is refreshed
  }

  static List<CartItem> getCartItems() {
    if (!_isInitialized) {
      throw Exception('DataIO not initialized. Call DataIO.init() first.');
    }
    return _cartItemsCache;
  }

  static Future<void> updateCartItemTimes(
    String id,
    String note,
    int newTimes,
  ) async {
    if (!_isInitialized) {
      init();
    }
    final key = id + note;
    final item = _cartItemsCache.firstWhere(
      (cartItem) => cartItem.id == id && cartItem.note == note,
      orElse: () => CartItem(
        id: '',
        thumbnail: '',
        title: '',
        addOns: [],
        note: '',
        totalPrice: 0,
        times: 0,
      ),
    );
    if (item.id.isNotEmpty) {
      if (newTimes <= 0) {
        await cartBox.delete(key);
        _cartItemsCache.removeWhere(
          (cartItem) => cartItem.id == id && cartItem.note == note,
        );
      } else {
        final updatedItem = CartItem(
          id: item.id,
          thumbnail: item.thumbnail,
          title: item.title,
          addOns: item.addOns,
          note: item.note,
          totalPrice: item.totalPrice,
          times: newTimes,
        );
        await cartBox.put(key, updatedItem.toJson());
        _cartItemsCache = _cartItemsCache
            .map((e) => e.id == id && e.note == note ? updatedItem : e)
            .toList();
      }
      await _updateCartItemsCache(); // Refresh cache after update
    }
  }
}
