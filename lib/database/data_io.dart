import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item.dart';
import '../models/raw_data.dart';
import '../service/api_service.dart';
import 'package:intl/intl.dart';

import '../utils/parse_date.dart';

class DataIO {
  static late Box settingsBox;
  static late Box<Map> cartBox;
  static List<CartItem> _cartItemsCache = [];
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    try {
      await Hive.initFlutter().timeout(Duration(seconds: 5));
      settingsBox = await Hive.openBox(
        'settings',
      ).timeout(Duration(seconds: 5));
      cartBox = await Hive.openBox<Map>(
        'cartBox',
      ).timeout(Duration(seconds: 5));
      _isInitialized = true;
      await _updateCartItemsCache();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> setNeedsRestart() async {
    if (!_isInitialized) await init();
    await settingsBox.put('needsRestart', true);
  }

  static bool getNeedsRestart() {
    if (!_isInitialized) return false;
    return settingsBox.get('needsRestart', defaultValue: false) as bool;
  }

  static Future<void> clearNeedsRestart() async {
    if (!_isInitialized) await init();
    await settingsBox.put('needsRestart', false);
  }

  // Helper method to safely convert dynamic map to Map<String, dynamic>
  static Map<String, dynamic> _convertToStringMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map<dynamic, dynamic>) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  // Info methods
  static Future<void> saveInfo(Info info) async {
    var box = await Hive.openBox('infoBox');
    await box.put('info', info.toJson());
  }

  static Future<Info?> fetchInfo() async {
    var box = await Hive.openBox('infoBox');
    final infoData = box.get('info');

    if (infoData == null) {
      return null;
    }

    try {
      final infoMap = _convertToStringMap(infoData);
      return Info.fromJson(infoMap);
    } catch (e) {
      print('Error parsing Info: $e');
      return null;
    }
  }

  static Future<bool> hasInfo() async {
    var box = await Hive.openBox('infoBox');
    return box.containsKey('info');
  }

  // Special methods
  static Future<void> saveSpecial(Special special) async {
    var box = await Hive.openBox('specialBox');
    await box.put('special', special.toJson());
  }

  static Future<Special?> fetchSpecial() async {
    var box = await Hive.openBox('specialBox');
    final specialData = box.get('special');

    if (specialData == null) {
      return null;
    }

    try {
      final specialMap = _convertToStringMap(specialData);
      return Special.fromJson(specialMap);
    } catch (e) {
      print('Error parsing Special: $e');
      return null;
    }
  }

  static Future<bool> hasSpecial() async {
    var box = await Hive.openBox('specialBox');
    return box.containsKey('special');
  }

  static Future<bool> isSpecialActive() async {
    final special = await fetchSpecial();
    if (special == null) return false;

    final now = DateTime.now();

    try {
      // Check if current day matches
      final currentDay = DateFormat('EEEE').format(now).toLowerCase();
      final isValidDay =
          special.day == 'all' ||
          special.day.toLowerCase().split(',').contains(currentDay);

      // Check if within date range
      bool isValidDate = true;
      if (special.end.isNotEmpty) {
        final endDate = parseDate(special.end);
        if (endDate != null) {
          isValidDate = now.isBefore(endDate.add(const Duration(days: 1)));
        }
      }

      return isValidDay && isValidDate;
    } catch (e) {
      print('Error checking special activity: $e');
      return false;
    }
  }

  // Get special with activity status
  static Future<Map<String, dynamic>?> fetchSpecialWithStatus() async {
    final special = await fetchSpecial();
    if (special == null) return null;

    final isActive = await isSpecialActive();

    return {'special': special, 'isActive': isActive};
  }

  // Slide methods
  static Future<void> saveSlides(List<Slide> slides) async {
    var box = await Hive.openBox('slidesBox');
    await box.put('slides', slides.map((s) => s.toJson()).toList());
  }

  static Future<List<Slide>> fetchAvailableSlides() async {
    var box = await Hive.openBox('slidesBox');
    final list = box.get('slides', defaultValue: []) as List;
    final slides = list.map((e) {
      final slideMap = _convertToStringMap(e);
      return Slide.fromJson(slideMap);
    }).toList();

    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();

    return slides.where((slide) {
      // ✅ Check date range
      bool isValidDate = true;
      if (slide.end.isNotEmpty) {
        final endDate = parseDate(slide.end);
        if (endDate != null) {
          isValidDate = now.isBefore(endDate.add(const Duration(days: 1)));
        } else {
          isValidDate = false; // invalid or unparsable date
        }
      }

      // ✅ Check allowed day(s)
      bool isValidDay =
          slide.day == 'all' ||
          slide.day.toLowerCase().split(',').contains(currentDay);

      return isValidDate && isValidDay;
    }).toList();
  }

  static Future<void> saveAdBanners(List<AdBanner> adBanners) async {
    var box = await Hive.openBox('adBannersBox');
    await box.put('adBanners', adBanners.map((a) => a.toJson()).toList());
  }

  static Future<List<AdBanner>> fetchAdBanners() async {
    var box = await Hive.openBox('adBannersBox');
    final list = box.get('adBanners', defaultValue: []) as List;
    return list.map((e) {
      final adBannerMap = _convertToStringMap(e);
      return AdBanner.fromJson(adBannerMap);
    }).toList();
  }

  static Future<AdBanner?> fetchAdBannerById(String adId) async {
    var box = await Hive.openBox('adBannersBox');
    final list = box.get('adBanners', defaultValue: []) as List;
    final adBanners = list.map((e) {
      final adBannerMap = _convertToStringMap(e);
      return AdBanner.fromJson(adBannerMap);
    }).toList();

    try {
      return adBanners.firstWhere((ad) => ad.id == adId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveCategories(List<Category> categories) async {
    var box = await Hive.openBox('categoriesBox');
    await box.put('categories', categories.map((c) => c.toJson()).toList());
  }

  static Future<List<Category>> fetchFoodCategories() async {
    var box = await Hive.openBox('categoriesBox');
    final list = box.get('categories', defaultValue: []) as List;
    return list
        .map((e) {
          final categoryMap = _convertToStringMap(e);
          return Category.fromJson(categoryMap);
        })
        .where((c) => c.food)
        .toList();
  }

  static Future<List<Category>> fetchDrinkCategories() async {
    var box = await Hive.openBox('categoriesBox');
    final list = box.get('categories', defaultValue: []) as List;
    return list
        .map((e) {
          final categoryMap = _convertToStringMap(e);
          return Category.fromJson(categoryMap);
        })
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
        .map((e) {
          final listMap = _convertToStringMap(e);
          return ListElement.fromJson(listMap);
        })
        .where((l) => (l.category).contains(categoryId))
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
        .map((e) {
          final addOnMap = _convertToStringMap(e);
          return AddOn.fromJson(addOnMap);
        })
        .where((l) => type == null || l.type == type)
        .toList();
  }

  static Future<void> saveDataFromApi(RawData data) async {
    await saveInfo(data.info);
    await saveSpecial(data.special);
    await saveSlides(data.slide);
    await saveAdBanners(data.adBanner);
    await saveCategories(data.categories);
    await saveLists(data.lists);
    await saveAddOns(data.addOn);
    await setNeedsRestart();
  }

  static Future<void> fetchDataAndSave(ApiService apiService) async {
    final rawdata = await apiService.getRawData();
    if (rawdata == null) {
      throw Exception('API returned null data');
    }
    await saveDataFromApi(rawdata);
  }

  // Check if we have any data saved
  static Future<bool> hasData() async {
    return await hasInfo() ||
        await hasSpecial() ||
        await _hasSlides() ||
        await _hasCategories();
  }

  static Future<bool> _hasSlides() async {
    var box = await Hive.openBox('slidesBox');
    final list = box.get('slides', defaultValue: []) as List;
    return list.isNotEmpty;
  }

  static Future<bool> _hasCategories() async {
    var box = await Hive.openBox('categoriesBox');
    final list = box.get('categories', defaultValue: []) as List;
    return list.isNotEmpty;
  }

  static Future<List<ListElement>> searchLists({
    String? type,
    String? query,
  }) async {
    var box = await Hive.openBox('listsBox');
    final list = box.get('lists', defaultValue: []) as List;
    final lowerQuery = query?.toLowerCase() ?? '';
    return list
        .map((e) {
          final listMap = _convertToStringMap(e);
          return ListElement.fromJson(listMap);
        })
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
    final allLists = list.map((e) {
      final listMap = _convertToStringMap(e);
      return ListElement.fromJson(listMap);
    }).toList();
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
        .map((e) {
          final cartMap = _convertToStringMap(e);
          return CartItem.fromJson(cartMap);
        })
        .toList()
        .toSet()
        .toList();
  }

  static Future<void> addToCart(CartItem item) async {
    if (!_isInitialized) {
      await init();
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
    await _updateCartItemsCache();
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
      await init();
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
      await _updateCartItemsCache();
    }
  }

  static Future<void> setAutoPlayDuration(Duration duration) async {
    if (!_isInitialized) await init();
    await settingsBox.put('autoPlayDuration', duration.inSeconds);
  }

  static Duration getAutoPlayDuration() {
    if (!_isInitialized) return const Duration(seconds: 5);
    return Duration(
      seconds: settingsBox.get('autoPlayDuration', defaultValue: 5),
    );
  }
}
