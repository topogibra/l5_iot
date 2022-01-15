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
  late final bool _isFavorite;

  ShoppingCart(this._setFAButton, this._setIconButton, this._resetIndex,
      {bool isFavorite = false, Key? key})
      : super(key: key) {
    this._isFavorite = isFavorite;
  }

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final TextEditingController textFieldController = TextEditingController();
  final TextEditingController priceTextFieldController =
      TextEditingController();
  final TextEditingController qttyTextFieldController = TextEditingController();
  late Future<List<ProductModel>> shoppingCart;
  late Future<List<ProductModel>> Function() _getCarts;
  late UserModel user;
  bool _init = true;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context);
    widget._setFAButton(FloatingActionButton(
      onPressed: () => displayDialog(context, user),
      child: Icon(Icons.add),
    ));

    if (_init) {
      _getCarts = () {
        return user.getCart(favorite: widget._isFavorite);
      };
      shoppingCart = _getCarts();
      _init = false;
    }

    return FutureBuilder<List<ProductModel>>(
      future: shoppingCart,
      builder: (context, snapshot) {
        return RefreshIndicator(
            child: _listView(snapshot), onRefresh: _pullRefresh);
      },
    );
  }

  Widget _listView(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          return ShoppingListItem(
            product: snapshot.data[index],
            inCart: snapshot.data.contains(snapshot.data[index]),
            onCartChanged: onCartChanged,
            onSwipeEndToStart: onSwipeEndToStart,
            onSwipeStartToEnd: onSwipeStartToEnd,
            notDismiss: widget._isFavorite,
            index: index,
          );
        },
      );
    }
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Fetching Data...'),
          )
        ]));
  }

  Future<void> _pullRefresh() async {
    List<ProductModel> freshShoppingCart = await _getCarts();
    setState(() {
      shoppingCart = Future.value(freshShoppingCart);
    });
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
                  if (textFieldController.text.trim() != "" &&
                      priceTextFieldController.text.isNotEmpty) {
                    ProductModel product = ProductModel(
                        name: textFieldController.text,
                        price: double.parse(priceTextFieldController.text),
                        quantity: double.parse(qttyTextFieldController.text),
                        uid: user.uid);
                    await product.add();
                    List<ProductModel> sCart = await shoppingCart;
                    sCart.add(product);
                    setState(() {
                      shoppingCart = Future.value(sCart);
                    });
                  }

                  textFieldController.clear();
                  priceTextFieldController.clear();
                  qttyTextFieldController.clear();
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
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProductPage(product: product)));
  }

  Future<bool> onSwipeStartToEnd(ProductModel product) async {
    List<ProductModel> sCart = await shoppingCart;
    sCart.remove(product);
    setState(() {
      shoppingCart = Future.value(sCart);
    });
    await product.remove();
    return true;
  }

  bool onSwipeEndToStart(ProductModel product) {
    product.favorite = true;
    return false;
  }
}
