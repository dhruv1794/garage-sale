import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/product_detail.dart';
import './screens/product_overview.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './providers/orders.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';

import './helpers/custom_routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products('', '', []),
          update: (ctx, authData, previousProducts) => Products(
            authData.token,
            authData.userId,
            previousProducts != null ? previousProducts.items : [],
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders('', '', []),
          update: (ctx, authData, previousOrders) => Orders(
            authData.token,
            authData.userId,
            previousOrders != null ? previousOrders.orders : [],
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.deepOrange),
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              })),
          home: authData.isLoggedIn
              ? const ProductOverview()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            ProductDetail.routeName: (ctx) => const ProductDetail(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductScreen.routeName: (ctx) => const UserProductScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            ProductOverview.routeName: (ctx) => const ProductOverview(),
          },
        ),
      ),
    );
  }
}
