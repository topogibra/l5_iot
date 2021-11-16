import 'package:flutter/material.dart';

class Product {
  final String name;

  const Product({@required this.name});
}

typedef void CartChangedCallback(Product product, bool inCart);
typedef bool SwipeCallback(Product product);

class ShoppingListItem extends StatelessWidget {
  final Product product;
  final inCart;
  final CartChangedCallback onCartChanged;
  final SwipeCallback onSwipeStartToEnd;
  final SwipeCallback onSwipeEndToStart;

  ShoppingListItem({
    @required this.product,
    @required this.inCart,
    @required this.onCartChanged,
    @required this.onSwipeStartToEnd,
    @required this.onSwipeEndToStart
  });

  @override
  Widget build(BuildContext context) {
    var listTile = ListTile(
      title: Text(product.name),
      leading: CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text(product.name[0]),
      ),
      onTap: () {
        onCartChanged(product, inCart);
      },
    );

    return Dismissible(
      key: ValueKey(product.name),
      child: listTile,
      confirmDismiss: (direction) async {
        if(direction == DismissDirection.startToEnd){
          return this.onSwipeStartToEnd(product);
        }
        if(direction == DismissDirection.endToStart){
          return this.onSwipeEndToStart(product);
        }
        return false;
      },
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerStart,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.green[500],
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        child: Icon(
          Icons.star,
          color: Colors.white,
        ),
      ),
    );
  }
}
