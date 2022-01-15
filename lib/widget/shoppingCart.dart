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
  final Function(Widget?) _setTitle;
  late final bool _isFavorite;

  ShoppingCart(
      this._setFAButton, this._setIconButton, this._resetIndex, this._setTitle,
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
  final TextEditingController searchFilterController = TextEditingController();
  late Future<List<ProductModel>> _shoppingCart, _searchingList;
  late Future<List<ProductModel>> Function() _getCarts;
  late UserModel user;
  bool _init = true;

  bool showSearchIcon = true;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context);

    widget._setFAButton(FloatingActionButton(
      onPressed: () => displayDialog(context, user),
      child: Icon(Icons.add),
    ));

    widget._setIconButton(_iconButton());
    if (_init) {
      _getCarts = () {
        return user.getCart(favorite: widget._isFavorite);
      };
      _shoppingCart = _getCarts();
      _searchingList = Future.value([]);
      _init = false;
    }

    return FutureBuilder<List<ProductModel>>(
      future: !showSearchIcon ? _searchingList : _shoppingCart,
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
            inFavorite: widget._isFavorite
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
      _shoppingCart = Future.value(freshShoppingCart);
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
                    List<ProductModel> sCart = await _shoppingCart;
                    sCart.add(product);
                    setState(() {
                      _shoppingCart = Future.value(sCart);
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
    List<ProductModel> sCart = await _shoppingCart;
    sCart.remove(product);
    setState(() {
      _shoppingCart = Future.value(sCart);
    });
    await product.remove();
    return true;
  }

  Future<bool> onSwipeEndToStart(ProductModel product) async{
    List<ProductModel> sCart = await _shoppingCart;
    sCart.remove(product);
    setState(() {
      _shoppingCart = Future.value(sCart);
    });
    product.favorite = !widget._isFavorite;
    return false;
  }

  IconButton? _iconButton() {
    return showSearchIcon
        ? IconButton(
            onPressed: () {
              setState(() {
                this._searchingList = Future.value([]);
                this.showSearchIcon = false;
                widget._setTitle(Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Search...',
                          contentPadding: EdgeInsets.all(5),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                this.showSearchIcon = true;
                                this.searchFilterController.clear();
                                widget._setTitle(null);
                              });
                            },
                          )),
                      controller: this.searchFilterController,
                      onChanged: (String value) async {
                        List<ProductModel> shoppingCart =
                            await this._shoppingCart;
                        List<ProductModel> searchingList = [];
                        shoppingCart.forEach((product) {
                          if (product.name.contains(value)) {
                            searchingList.add(product);
                          }
                        });
                        setState(() {
                          this._shoppingCart = Future.value(shoppingCart);
                          this._searchingList = Future.value(searchingList);
                        });
                      },
                    ),
                  ),
                ));
              });
            },
            icon: Icon(Icons.search))
        : null;
  }
}
