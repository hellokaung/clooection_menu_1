import 'package:flutter/material.dart';
import '../database/data_io.dart';
import '../models/raw_data.dart';
import '../service/api_service.dart';

class HomeProvider extends ChangeNotifier {
  late Duration autoPlayDuration;
  int currentSlideIndex = 0;
  List<Category> foodCategories = [];
  List<Category> drinkCategories = [];
  List<ListElement> foodsInSelectedCategory = [];
  String currentCategory = "";
  List<Slide> slides = [];
  List<AdBanner> adBanners = [];
  int selectedTab = 0; // 0 = Food, 1 = Drink
  int selectedCategoryIndex = 0;
  bool loading = true;
  String? error;
  bool showRestartNotice = false;

  HomeProvider() {
    autoPlayDuration = DataIO.getAutoPlayDuration();
    _init();
  }

  Future<void> _init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      // Fetch initial data from Hive
      await Future.wait([
        DataIO.fetchFoodCategories().then((value) => foodCategories = value),
        DataIO.fetchDrinkCategories().then((value) => drinkCategories = value),
        DataIO.fetchAvailableSlides().then((value) => slides = value),
        DataIO.fetchAdBanners().then((value) => adBanners = value),
      ]);

      // Check if data is empty and refresh from API if needed
      if (foodCategories.isEmpty &&
          drinkCategories.isEmpty &&
          slides.isEmpty &&
          adBanners.isEmpty) {
        await _refreshFromApi();
      } else {
        // Check for updates in the background
        _updateFromApiAndCheckChanges();
      }

      // Set default category index
      if (foodCategories.isNotEmpty) {
        final firstFood = foodCategories.firstWhere(
          (cat) => cat.food,
          orElse: () => foodCategories.first,
        );
        selectedCategoryIndex = foodCategories.indexOf(firstFood);
      } else {
        selectedCategoryIndex = 0;
      }

      // Check restart flag from DataIO
      showRestartNotice = DataIO.getNeedsRestart();
      loading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to load data: $e';
      print(error);
      loading = false;
      notifyListeners();
    }
  }

  void setAutoPlayDuration(Duration duration) {
    autoPlayDuration = duration;
    DataIO.setAutoPlayDuration(duration);
    notifyListeners();
  }

  void setCurrentSlideIndex(int index) {
    currentSlideIndex = index;
    notifyListeners();
  }

  Future<void> _refreshFromApi() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final apiService = ApiService();
      final rawdata = await apiService.getRawData();
      if (rawdata == null) {
        error = 'Failed to fetch data from API';
        loading = false;
        notifyListeners();
        return;
      }
      await DataIO.saveDataFromApi(rawdata);
      await Future.wait([
        DataIO.fetchFoodCategories().then((value) => foodCategories = value),
        DataIO.fetchDrinkCategories().then((value) => drinkCategories = value),
        DataIO.fetchAvailableSlides().then((value) => slides = value),
        DataIO.fetchAdBanners().then((value) => adBanners = value),
      ]);
      loading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to fetch data from API: $e';
      print(error);
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _updateFromApiAndCheckChanges() async {
    try {
      final apiService = ApiService();
      final oldFood = List<Category>.from(foodCategories);
      final oldDrink = List<Category>.from(drinkCategories);
      final oldSlides = List<Slide>.from(slides);
      final oldAdBanners = List<AdBanner>.from(adBanners);
      final rawdata = await apiService.getRawData();
      if (rawdata == null) return;

      await DataIO.saveDataFromApi(rawdata);

      final newFood = await DataIO.fetchFoodCategories();
      final newDrink = await DataIO.fetchDrinkCategories();
      final newSlides = await DataIO.fetchAvailableSlides();
      final newAdBanners = await DataIO.fetchAdBanners();

      // Check if any data has changed
      if (!_listEquals(oldFood, newFood, (a, b) => a.id == b.id) ||
          !_listEquals(oldDrink, newDrink, (a, b) => a.id == b.id) ||
          !_listEquals(oldSlides, newSlides, (a, b) => a.id == b.id) ||
          !_listEquals(oldAdBanners, newAdBanners, (a, b) => a.id == b.id)) {
        showRestartNotice = true;
      }

      // Update local data
      foodCategories = newFood;
      drinkCategories = newDrink;
      slides = newSlides;
      adBanners = newAdBanners;
      notifyListeners();
    } catch (e) {
      print('Error updating from API: $e');
    }
  }

  bool _listEquals<T>(List<T> a, List<T> b, [bool Function(T, T)? equals]) {
    if (a.length != b.length) return false;
    if (equals == null) return a == b;
    for (int i = 0; i < a.length; i++) {
      if (!equals(a[i], b[i])) return false;
    }
    return true;
  }

  void retry() {
    error = null;
    _init();
  }

  void setTab(int index) {
    selectedTab = index;
    selectedCategoryIndex = 0;
    setCategory(selectedCategoryIndex);
    notifyListeners();
  }

  void setCategory(int index) {
    if (currentCategory != currentCategories[index].id) {
      selectedCategoryIndex = index;
      currentCategory = currentCategories[selectedCategoryIndex].id;
      setfoodLists();
      notifyListeners();
    }
  }

  void setfoodLists() async {
    foodsInSelectedCategory = await DataIO.fetchListsByCategory(
      currentCategory,
    );
    notifyListeners();
  }

  List<Category> get currentCategories =>
      selectedTab == 0 ? foodCategories : drinkCategories;

  String? get selectedCategoryId => currentCategories.isNotEmpty
      ? currentCategories[selectedCategoryIndex].id
      : null;

  List<Slide> get availableSlides => slides;

  Future<AdBanner?> getAdBannerById(String adId) async {
    return await DataIO.fetchAdBannerById(adId);
  }

  Future<void> clearRestartNotice() async {
    showRestartNotice = false;
    await DataIO.clearNeedsRestart();
    await _init();
    notifyListeners();
  }
}
