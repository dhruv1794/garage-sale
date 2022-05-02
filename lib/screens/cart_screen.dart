import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widgets/cart_item_gui.dart';
import '../widgets/order_button.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartContainer = Provider.of<Cart>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          '\$ ${cartContainer.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      OrderButton(cartContainer: cartContainer),
                    ],
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: cartContainer.itemCount,
              itemBuilder: (ctx, i) => CartItemGUI(
                id: cartContainer.items.values.toList()[i].id,
                productId: cartContainer.items.keys.toList()[i],
                title: cartContainer.items.values.toList()[i].title,
                price: cartContainer.items.values.toList()[i].price,
                quantity: cartContainer.items.values.toList()[i].quantity,
              ),
            ))
          ],
        ));
  }
}
