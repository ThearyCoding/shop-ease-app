import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/models/cart_item.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/providers/cart_notifier.dart';
import 'package:e_commerce/providers/wishlist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart/my_cart_screen.dart';

class ProductDetail extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  ConsumerState<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<ProductDetail> {

  final storages = ["1B", "825G", "512G"];
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProductInWishlist = ref
        .watch(wishlistStateNotifierProvider)
        .products
        .any((product) => product.id == widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NotificationListener(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                _scrollOffsetNotifier.value = _scrollController.offset;
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  expandedHeight: 350,
                  leading: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: EdgeInsets.all(10),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .6),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                      ),
                    ),
                  ),
                  actions: [
                    InkWell(
                      radius: 20,
                      onTap: () async {
                        if (isProductInWishlist) {
                          await ref
                              .read(wishlistStateNotifierProvider.notifier)
                              .removeWishlist(widget.product.id ?? '');
                        } else {
                          await ref
                              .read(wishlistStateNotifierProvider.notifier)
                              .addWishlist(widget.product);
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: .2),
                        ),
                        child: Icon(
                          isProductInWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isProductInWishlist ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .6),
                      ),
                      child: Icon(Icons.share),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: ValueListenableBuilder<double>(
                      valueListenable: _scrollOffsetNotifier,
                      builder: (context, offset, child) {
                        double opacity = offset > 150 ? 1.0 : 0.0;
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            widget.product.name!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    background: Container(
                      decoration: BoxDecoration(color: Color(0xffF1F3F2)),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                                tag: widget.product.id!,
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.images[0],
                                  width: MediaQuery.of(context).size.width,
                                  // fit: BoxFit.cover,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.product.name!,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.local_offer,
                                    color: Colors.white,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor: Color(0xffEF4C4C)),
                                  onPressed: () {},
                                  label: Text(
                                    "On Sale",
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.orange, size: 24),
                                  SizedBox(width: 5),
                                  Text(
                                    widget.product.ratings.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '(117 reviews)',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite_border,
                                    color: Colors.grey, size: 28),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Text(
                            widget.product.description ?? "No description provided",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 10),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: storages.length,
                                itemBuilder: (ctx, index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: index != 0
                                            ? Border.all(color: Colors.black)
                                            : Border(),
                                        borderRadius: BorderRadius.circular(10),
                                        color: index == 0
                                            ? Colors.green
                                            : Colors.transparent),
                                    child: Text(
                                      storages[index],
                                      style: TextStyle(
                                          color: index == 0
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\$${widget.product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "\$500.00",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cartStateNotifierProvider.notifier).addProduct(
                          CartItem(
                              product: widget.product, quantity: 1, id: ''));

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("${widget.product.name} added to cart!")));
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return MyCartScreen();
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
