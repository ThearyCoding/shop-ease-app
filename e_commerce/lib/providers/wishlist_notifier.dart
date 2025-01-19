import 'package:e_commerce/models/wishlist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../services/apis/wishlist_api.dart';

class WishlistNotifier extends StateNotifier<Wishlist> {
  final WishlistApi _wishlistApi;
  WishlistNotifier(this._wishlistApi) : super(Wishlist.empty());

  // Future<void> addWishlist(String productId) async {
  //   await _wishlistApi.addWishlist(productId);
  //    await fetchWishlists();
  // }

  Future<void> fetchWishlists() async {
    final wishlists = await _wishlistApi.fetchWishlists();
    state = wishlists ?? Wishlist.empty();
  }

  Future<void> addWishlist(Product product) async {
    // Add the product to the wishlist via the API
    await _wishlistApi
        .addWishlist(product.id ?? ''); // Use product.id instead of productId

    // Update the local state by adding the existing product to the wishlist
    state = state.copyWith(
      products: [
        ...state.products,
        product
      ], // Directly add the passed product to the state
    );
  }

  Future<void> removeWishlist(String productId) async {
    // Remove the product from the wishlist via the API
    await _wishlistApi.removeProductFromWishlist(productId);

    // Update the local state by removing the product from the wishlist
    state = state.copyWith(
      products:
          state.products.where((product) => product.id != productId).toList(),
    );
  }
}

final wishlistStateNotifierProvider =
    StateNotifierProvider<WishlistNotifier, Wishlist>((ref) {
  final api = ref.watch(wishlistApiProvider);

  return WishlistNotifier(api);
});
