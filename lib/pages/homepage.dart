import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l5_iot/model/user.dart';
import 'package:l5_iot/pages/productPage.dart';
import 'package:l5_iot/pages/registerPage.dart';
import 'package:l5_iot/shoppingListItem.dart';

import '../model/product.dart';
import 'loginPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textFieldController = TextEditingController();
  final TextEditingController priceTextFieldController =
      TextEditingController();
  final TextEditingController qttyTextFieldController = TextEditingController();
  final TextEditingController searchFilterController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController uidController = TextEditingController();

  List<ProductModel> shoppingCart = [
    ProductModel(name: "apples", price: 2.0, quantity: 4),
    ProductModel(name: "pears", price: 2.0, quantity: 4)
  ];
  List<ProductModel> favorites = [];
  List<ProductModel> searchingList = [];
  int bottomIndex = 0;

  Widget? searchBar;
  bool searchIcon = true;
  bool editProfile = false;
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    List<ProductModel> listProducts =
        (searchIcon) ? shoppingCart : searchingList;
    listProducts = (bottomIndex == 1) ? favorites : listProducts;
    var listView = Expanded(
      child: ListView.builder(
          itemCount: listProducts.length,
          itemBuilder: (context, index) {
            return ShoppingListItem(
              product: listProducts[index],
              inCart: listProducts.contains(listProducts[index]),
              onCartChanged: onCartChanged,
              onSwipeEndToStart: onSwipeEndToStart,
              onSwipeStartToEnd: onSwipeStartToEnd,
              notDismiss: bottomIndex == 1,
            );
          }),
    );

    Widget iconButton = IconButton(
        onPressed: () {
          setState(() {
            this.searchingList = [];
            this.searchIcon = false;
            this.searchBar = Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Search...',
                      contentPadding: EdgeInsets.all(5),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            this.searchIcon = true;
                            this.searchBar = Text(widget.title);
                            this.searchFilterController.clear();
                          });
                        },
                      )),
                  controller: this.searchFilterController,
                  onChanged: (String value) async {
                    this.searchingList.clear();
                    this.shoppingCart.forEach((product) {
                      if (product.name.contains(value)) {
                        setState(() {
                          this.searchingList.add(product);
                        });
                      }
                    });
                  },
                ),
              ),
            );
          });
        },
        icon: Icon(Icons.search));

    Widget body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (bottomIndex != 1)
          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Image.asset(
                  "assets/toDo.png",
                  width: 50,
                  height: 50,
                ),
                Text(
                  "Products you have to buy",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                )
              ],
            ),
          ),
        listView
      ],
    );

    if (searchBar == null) searchBar = Text(widget.title);

    if (bottomIndex == 2) {
      if (UserModel.authenticated) {
        nameController.text = UserModel.name;
        surnameController.text = UserModel.surname;
        emailController.text = UserModel.email;
        uidController.text = UserModel.uuid;
      }
      searchBar = Text("Profile");
      iconButton = IconButton(
          onPressed: () => setState(() => {editProfile = !editProfile}),
          icon: Icon(editProfile ? Icons.edit : Icons.edit_outlined));
      body = Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1, child: Text("First Name")),
                  Expanded(
                    flex: 2,
                    child: TextField(
                        controller: nameController, enabled: editProfile),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1, child: Text("Surname")),
                  Expanded(
                      flex: 2,
                      child: TextField(
                          controller: surnameController, enabled: editProfile)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1, child: Text("Email")),
                  Expanded(
                      flex: 2,
                      child: TextField(
                          controller: emailController, enabled: false)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1, child: Text("Uid")),
                  Expanded(
                      flex: 2,
                      child: TextField(
                          controller: uidController, enabled: editProfile)),
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(flex: 1, child: Text("Verified")),
                      Expanded(
                          flex: 2,
                          child: Icon(
                              UserModel.verified ? Icons.check : Icons.close)),
                    ],
                  )),
            ],
          ));
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: searchBar,
        actions: [if (this.searchIcon) iconButton],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => displayDialog(context),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: bottomIndex,
        onTap: (index) {
          setState(() {
            this.bottomIndex = index;
          });
          if (index == 2) {
            // if user not signed in
            if (!UserModel.authenticated)
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginPage()));
            else {}
          }
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future displayDialog(BuildContext context) {
    var doubleInputFormattter = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
      TextInputFormatter.withFunction((oldValue, newValue) {
        try {
          final text = newValue.text;
          if (text.isNotEmpty) double.parse(text);
          return newValue;
        } catch (e) {}
        return oldValue;
      })
    ];
    Column textfields = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: textFieldController,
          decoration: InputDecoration(hintText: 'Product name'),
        ),
        TextField(
            controller: priceTextFieldController,
            decoration: InputDecoration(suffixIcon: Icon(Icons.euro)),
            keyboardType: TextInputType.number,
            inputFormatters: doubleInputFormattter),
        TextField(
            controller: qttyTextFieldController,
            decoration: InputDecoration(hintText: 'Product quantity'),
            keyboardType: TextInputType.number,
            inputFormatters: doubleInputFormattter),
      ],
    );

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Add a new product to your list",
              textAlign: TextAlign.center,
            ),
            content: textfields,
            actions: [
              TextButton(
                onPressed: () {
                  // print(textFieldController.text);
                  if (textFieldController.text.trim() != "" &&
                      priceTextFieldController.text.isNotEmpty)
                    setState(() {
                      shoppingCart.add(
                        ProductModel(
                            name: textFieldController.text,
                            price: double.parse(priceTextFieldController.text),
                            quantity:
                                double.parse(qttyTextFieldController.text)),
                      );
                    });

                  textFieldController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Save"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        });
  }

  void onCartChanged(ProductModel product, bool inCart) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProductPage(key: Key(product.name), product: product)));
  }

  bool onSwipeStartToEnd(ProductModel product) {
    setState(() {
      shoppingCart.remove(product);
    });
    return true;
  }

  bool onSwipeEndToStart(ProductModel product) {
    setState(() {
      favorites.add(product);
    });
    return false;
  }
}
