import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/products_grid.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/badge.dart';

import 'cart_screen.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductOverview extends StatefulWidget {
  static const routeName = '/product-overview';
  const ProductOverview({Key? key}) : super(key: key);

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  var _isInit = true;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  var showFavoritesOnly = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage Sale'),
        actions: <Widget>[
          PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.favorites) {
                    showFavoritesOnly = true;
                  } else {
                    showFavoritesOnly = false;
                  }
                });
              },
              icon: const Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      child: Text('Only Favorites'),
                      value: FilterOptions.favorites,
                    ),
                    const PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOptions.all,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
              color: cart.itemCount == 0
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.green,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductGrid(
              showFavs: showFavoritesOnly,
            ),
    );
  }
}
