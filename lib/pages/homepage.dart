import 'package:flutter/material.dart';
import 'package:l5_iot/widget/profile.dart';
import 'package:l5_iot/widget/shoppingCart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 2;
  List<Widget?> screens = [
    null,null,null
  ];

  IconButton? _iconButton;
  FloatingActionButton? _floatingActionButton;
  Widget? _title = Text("Shopping Cart");

  @override
  Widget build(BuildContext context) {
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

    setTitle(Widget? widget) {
      Future.delayed(Duration.zero, () => setState(() => _title = widget ?? Text("Shopping Cart")));
    }

    screens[0] = ShoppingCart(setFActionButton, setIconButton, setTitle,
        key: ValueKey("cart"));
    screens[1] = ShoppingCart(
      setFActionButton,
      setIconButton,
      setTitle,
      isFavorite: true,
    );
    screens[2] = Profile(setIconButton, setFActionButton, resetIndex);

    return Scaffold(
      appBar: AppBar(
        title: _title,
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
