import 'package:flutter/material.dart';
import 'package:l5_iot/auth/auth.dart';
import 'package:l5_iot/model/user.dart';
import 'package:l5_iot/widget/profile.dart';
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
    Center(child: Text("Icon"))
  ];

  IconButton? _iconButton;
  FloatingActionButton? _floatingActionButton;

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

    // screens[2] = StreamProvider<UserData?>.value(
    //     value: Provider.of<UserModel>(context).userData,
    //     initialData: null,
    //     child: Profile(setIconButton, setFActionButton));
    screens[2] = Profile(setIconButton, setFActionButton);

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
        }),
      ),
      floatingActionButton: _floatingActionButton,
    );
  }
}
