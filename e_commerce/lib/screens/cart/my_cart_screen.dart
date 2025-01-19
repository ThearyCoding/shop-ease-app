import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/providers/cart_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../product-screen/all_product.dart';

class MyCartScreen extends ConsumerStatefulWidget {
  const MyCartScreen({super.key});

  @override
  ConsumerState<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends ConsumerState<MyCartScreen> {
  @override
  void initState() {
    super.initState();

    _fetchCarts();
  }

  Future<void> _fetchCarts() async {
    ref.read(cartStateNotifierProvider.notifier).fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartStateNotifierProvider);
    final subtotal = cart.items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.product.price),
    );

    final deliveryFee = 5.00;
    final discount = 10.00;

    final total = subtotal + deliveryFee - discount;
    final chargesList = [
      {'name': 'Subtotal', 'value': subtotal},
      {'name': 'Delivery Fee', 'value': deliveryFee},
      {'name': 'Discount', 'value': -discount},
      {'name': 'Total', 'value': total},
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
        title: Text(
          "My Cart",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .6),
              ),
              child: Icon(
                Icons.more_horiz,
                size: 21,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? _buildCartEmpty()
                : ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(),
                    ),
                    itemBuilder: (ctx, index) {
                      final item = cart.items[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 150,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Color(0xffF1F3F2),
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      item.product.images[0]),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.product.name!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                      GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(cartStateNotifierProvider
                                                    .notifier)
                                                .removeCartItem(
                                                    cart.id, item.id);
                                          },
                                          child: Icon(Icons.close, size: 20)),
                                    ],
                                  ),
                                  Text("1T",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "\$${item.product.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                      Row(
                                        children: [
                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () async {
                                              await ref
                                                  .read(
                                                      cartStateNotifierProvider
                                                          .notifier)
                                                  .updateQuantity(
                                                    item.product,
                                                    item.quantity - 1,
                                                    cart.id,
                                                    item.id,
                                                  );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              child:
                                                  Icon(Icons.remove, size: 21),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(item.quantity.toString(),
                                              style: TextStyle(fontSize: 16)),
                                          SizedBox(width: 5),
                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            onTap: () async {
                                              await ref
                                                  .read(
                                                      cartStateNotifierProvider
                                                          .notifier)
                                                  .updateQuantity(
                                                    item.product,
                                                    item.quantity + 1,
                                                    cart.id,
                                                    item.id,
                                                  );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              child: Icon(Icons.add, size: 21),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          cart.items.isEmpty
              ? SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chargesList.length,
                        itemBuilder: (ctx, index) {
                          return ListTile(
                            title: Text("${chargesList[index]['name']}"),
                            trailing: Text("\$${chargesList[index]['value']}"),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFF19C463),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {},
                        child: Text(
                          "CheckOut for \$${chargesList.last['value']}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Center _buildCartEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            repeat: false,
            'assets/animations/cart-empty.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 20),
          Text(
            "Your cart is empty",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Looks like you haven't added anything to your cart yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => AllProductScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Explore Products",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
