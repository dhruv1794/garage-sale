import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cartContainer,
  }) : super(key: key);

  final Cart cartContainer;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: (widget.cartContainer.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cartContainer.items.values.toList(),
                  widget.cartContainer.totalAmount);

              setState(() {
                _isLoading = false;
              });
              widget.cartContainer.clearCart();
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('Order Now'),
    );
  }
}
