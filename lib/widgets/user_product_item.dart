import 'package:flutter/material.dart';
import '../screens/edit_product_screen.dart';

import 'package:provider/provider.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;
  const UserProductItem(
      {required this.title, required this.imageUrl, required this.id, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                } catch (error) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                        content: Text(
                      'Delteting failed',
                      textAlign: TextAlign.center,
                    )),
                  );
                }
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
