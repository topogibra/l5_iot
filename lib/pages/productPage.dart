import 'package:flutter/material.dart';
import 'package:l5_iot/model/product.dart';

class ProductPage extends StatelessWidget {
  final ProductModel product;
  ProductPage({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(product.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Name: ' + product.name),
              Text('Price :' + product.price.toStringAsFixed(2) + '€'),
              Text('Quantity: ' + product.quantity.toStringAsFixed(2))
            ],
          ),
        ));
  }
}
