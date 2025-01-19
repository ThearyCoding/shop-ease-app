import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wishlist_notifier.dart';

class WishListScreen extends ConsumerStatefulWidget {
  const WishListScreen({super.key});

  @override
  ConsumerState<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends ConsumerState<WishListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchWishLists();
  }

  Future<void> _fetchWishLists() async {
    await ref.read(wishlistStateNotifierProvider.notifier).fetchWishlists();
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistStateNotifierProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Wishlist'),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: wishlist.products.isEmpty
              ? Center(child: Text('No products in wishlist'))
              : ListView.builder(
                  itemCount: wishlist.products.length,
                  itemBuilder: (context, index) {
                    final product = wishlist.products[index];
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFFD9E1EC),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  product.images.first,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name ?? 'No name available',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '\$${product.price}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '(${product.ratings})',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await ref
                                  .read(wishlistStateNotifierProvider.notifier)
                                  .removeWishlist(product.id ?? '');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ));
  }
}
