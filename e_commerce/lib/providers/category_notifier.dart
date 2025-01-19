import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../services/apis/category_api.dart';

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;

  CategoryState({required this.categories, required this.isLoading});

  CategoryState copyWith({List<CategoryModel>? categories, bool? isLoading}) {
    return CategoryState(
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading);
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryApi _categoryApi;

  CategoryNotifier(this._categoryApi)
      : super(CategoryState(categories: List.empty(), isLoading: false));

  Future<void> fetchCategories() async {
    try {
      state = state.copyWith(isLoading: true);
      final categories = await _categoryApi.fetchCategories();
      categories.insert(0, CategoryModel(name: "All", id: 'all'));
      state = state.copyWith(categories: categories);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  final api = ref.read(categoryApiProvider);
  return CategoryNotifier(api);
});
