import 'package:flutter/material.dart';
import '../database/data_io.dart';
import '../models/raw_data.dart';
import '../service/api_service.dart';

class HomeProvider extends ChangeNotifier {
  List<Category> foodCategories = [];
  List<Category> drinkCategories = [];
  int selectedTab = 0; // 0 = Food, 1 = Drink
  int selectedCategoryIndex = 0;
  bool loading = true;
  String? error;
  bool showRestartNotice = false;

  HomeProvider() {
    _init();
  }

  Future<void> _init() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      foodCategories = await DataIO.fetchFoodCategories();
      drinkCategories = await DataIO.fetchDrinkCategories();

      if (foodCategories.isEmpty && drinkCategories.isEmpty) {
        await _refreshFromApi();
      } else {
        loading = false;
        notifyListeners();
        _updateFromApiAndCheckChanges();
      }

      if (foodCategories.isNotEmpty) {
        final firstFood = foodCategories.firstWhere(
          (cat) => cat.food,
          orElse: () => foodCategories.first,
        );
        selectedCategoryIndex = foodCategories.indexOf(firstFood);
      } else {
        selectedCategoryIndex = 0;
      }
      loading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to load data: $e';
      print(error);
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshFromApi() async {
    final apiService = ApiService();
    var rawdata = await apiService.getRawData();
    if (rawdata == null) return;
    await DataIO.saveDataFromApi(rawdata);
    foodCategories = await DataIO.fetchFoodCategories();
    drinkCategories = await DataIO.fetchDrinkCategories();
    loading = false;
    notifyListeners();
  }

  Future<void> _updateFromApiAndCheckChanges() async {
    final apiService = ApiService();
    final oldFood = List<Category>.from(foodCategories);
    final oldDrink = List<Category>.from(drinkCategories);
    var rawdata = await apiService.getRawData();
    if (rawdata == null) return;
    await DataIO.saveDataFromApi(rawdata);
    final newFood = await DataIO.fetchFoodCategories();
    final newDrink = await DataIO.fetchDrinkCategories();

    if (!_listEquals(oldFood, newFood) || !_listEquals(oldDrink, newDrink)) {
      showRestartNotice = true;
      notifyListeners();
    }
  }

  bool _listEquals(List<Category> a, List<Category> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
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
    notifyListeners();
  }

  void setCategory(int index) {
    selectedCategoryIndex = index;
    notifyListeners();
  }

  List<Category> get currentCategories =>
      selectedTab == 0 ? foodCategories : drinkCategories;

  String? get selectedCategoryId => currentCategories.isNotEmpty
      ? currentCategories[selectedCategoryIndex].id
      : null;

  /// Clears the restart notice and triggers a full data reload,
  /// effectively simulating the application restarting with fresh data.
  Future<void> clearRestartNotice() async {
    // 1. Clear the UI flag
    showRestartNotice = false;
    notifyListeners();

    // 2. Clear the persistent Hive flag (assuming DataIO.clearNeedsRestart() exists)
    // await DataIO.clearNeedsRestart();

    // 3. Re-initialize the provider to load the newly saved data.
    await _init();
  }
}
