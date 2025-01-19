import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductCart extends StatelessWidget {
  final Product product;
  const ProductCart({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Hero(
            tag: product.id ?? '',
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xffF1F3F2),
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(product.images[0]),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Expanded(child: Text(product.name!)),
              Row(
                children: [
                  Icon(
                    Icons.star_rate,
                    size: 15,
                    color: Color(0xffFF9D2A),
                  ),
                  SizedBox(width: 2),
                  Text(product.ratings.toString()),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text("\$${product.price.toStringAsFixed(2)}"),
        ),
      ],
    );
  }
}
