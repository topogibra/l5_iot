import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l5_iot/model/product.dart';
import 'package:l5_iot/model/user.dart';
import 'package:l5_iot/pages/productPage.dart';
import 'package:l5_iot/shoppingListItem.dart';
import 'package:provider/provider.dart';

class ShoppingCart extends StatefulWidget {
  final Function(IconButton?) _setIconButton;
  final Function(FloatingActionButton?) _setFAButton;
  final Function() _resetIndex;

  const ShoppingCart(this._setFAButton, this._setIconButton, this._resetIndex,
      {Key? key})
      : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final TextEditingController textFieldController = TextEditingController();
  final TextEditingController priceTextFieldController =
      TextEditingController();
  final TextEditingController qttyTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<ProductModel> shoppingCart = Provider.of<List<ProductModel>>(context);
    UserModel user = Provider.of<UserModel>(context);


    widget._setFAButton(FloatingActionButton(
      onPressed: () => displayDialog(context, user),
      child: Icon(Icons.add),
    ));

    return ListView.builder(itemCount: shoppingCart.length,itemBuilder: (context, index) {
      return ShoppingListItem(
              product: shoppingCart[index],
              inCart: shoppingCart.contains(shoppingCart[index]),
              onCartChanged: onCartChanged,
              onSwipeEndToStart: onSwipeEndToStart,
              onSwipeStartToEnd: onSwipeStartToEnd,
             );
    },);
  }

  Future displayDialog(BuildContext context, UserModel user) {
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
                onPressed: () async {
                  // print(textFieldController.text);
                  if (textFieldController.text.trim() != "" &&
                      priceTextFieldController.text.isNotEmpty) {
                    ProductModel product = ProductModel(
                        name: textFieldController.text,
                        price: double.parse(priceTextFieldController.text),
                        quantity: double.parse(qttyTextFieldController.text),
                        uid: user.uid);
                    await product.add();
                    setState(() {});
                    print("Add product");
                  }

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
    // setState(() {
    //   // shoppingCart.remove(product);
    // });
    print("remove product");
    return true;
  }

  bool onSwipeEndToStart(ProductModel product) {
    // setState(() {
    //   favorites.add(product);
    // });
    print("add to favorites");
    return false;
  }
}

