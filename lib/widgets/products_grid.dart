import 'package:flutter/material.dart';
import '../widgets/product_item.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;
  const ProductGrid({required this.showFavs, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              // ignore: prefer_const_constructors
              child: ProductItem(),
            ));
  }
}
