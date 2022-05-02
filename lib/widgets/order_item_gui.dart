import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../providers/orders.dart';

class OrderItemGUI extends StatefulWidget {
  final OrderItem order;
  const OrderItemGUI({required this.order, Key? key}) : super(key: key);

  @override
  State<OrderItemGUI> createState() => _OrderItemGUIState();
}

class _OrderItemGUIState extends State<OrderItemGUI> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 600),
      curve: Curves.fastOutSlowIn,
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text("\$ ${widget.order.amount}"),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
                curve: Curves.fastOutSlowIn,
                duration: const Duration(microseconds: 600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded
                    ? min(widget.order.products.length * 20.0 + 10, 100)
                    : 0,
                child: ListView(
                  children: widget.order.products
                      .map((prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                '${prod.quantity} X \$ ${prod.price}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }
}
