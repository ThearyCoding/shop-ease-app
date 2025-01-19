import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../services/apis/product_api.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;

  ProductState({required this.products, required this.isLoading});

  ProductState copyWith({List<Product>? products, bool? isLoading}) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductApi _productApi;

  ProductNotifier(this._productApi) : super(ProductState(products: [], isLoading: false));

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final products = await _productApi.fetchProducts();
      state = state.copyWith(products: products);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true);
    try {
      final products = await _productApi.fetchProductsByCategory(categoryId);
      state = state.copyWith(products: products);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final productStateNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final api = ref.watch(productApiProvider);
  return ProductNotifier(api);
});