import 'package:flutter/material.dart';
import 'package:l5_iot/auth/auth.dart';
import 'package:l5_iot/model/product.dart';
import 'package:l5_iot/model/user.dart';
import 'package:l5_iot/widget/profile.dart';
import 'package:l5_iot/widget/shoppingCart.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  List<Widget> screens = [
    Center(child: Text("Cart")),
    Center(child: Text("Icon")),
    Center(child: Text("Profile"))
  ];

  IconButton? _iconButton;
  FloatingActionButton? _floatingActionButton;

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserModel>(context);

    setFActionButton(FloatingActionButton? floatingActionButton) {
      Future.delayed(Duration.zero,
          () => setState(() => _floatingActionButton = floatingActionButton));
    }

    setIconButton(IconButton? iconButton) {
      Future.delayed(
          Duration.zero, () => setState(() => _iconButton = iconButton));
    }

    resetIndex() {
      Future.delayed(Duration.zero, () => setState(() => currentIndex = 0));
    }

    screens[0] = StreamProvider<List<ProductModel>>.value(
      value: user.cart,
      initialData: [],
      child: ShoppingCart(setFActionButton,setIconButton,resetIndex),
    );
    screens[2] = Profile(setIconButton, setFActionButton, resetIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Cart"),
        actions: [if (_iconButton != null) _iconButton as Widget],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: currentIndex,
        onTap: (index) => setState(() {
          currentIndex = index;
          _floatingActionButton = null;
          _iconButton = null;
        }),
      ),
      floatingActionButton: _floatingActionButton,
    );
  }
}
