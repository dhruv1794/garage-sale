import 'package:flutter/material.dart';
import '../screens/product_detail.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final productPrice = product.price.toString();
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GridTile(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(ProductDetail.routeName, arguments: product.id);
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    const AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        header: GridTileBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(product.title, textAlign: TextAlign.center)),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, value, _) => IconButton(
              icon: Icon(
                  product.isFavourite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () => {
                product.toggleFavoriteStatus(
                  authData.token!,
                  authData.userId!,
                )
              },
            ),
          ),
          title: Text('\$ $productPrice', textAlign: TextAlign.center),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () => {
              cart.addItem(product.id, product.price, product.title),
              ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added ${product.title} to cart !',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      cart.reduceQuantity(product.id);
                    },
                  ),
                ),
              )
            },
          ),
        ),
      ),
    );
  }
}
