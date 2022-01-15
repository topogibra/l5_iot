import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String name;
  final double price;
  final double quantity;
  late bool isFavorite;
  late final String key;
  late final String uid;
  late String id;

  late CollectionReference<Map<String, dynamic>> _productDataRef;

  ProductModel(
      {required this.name,
      required this.price,
      required this.quantity,
      required this.uid,
      this.isFavorite = false,
      this.id = "",
      this.key = ""}) {
    _productDataRef = FirebaseFirestore.instance
        .collection("products")
        .doc(uid)
        .collection("cart");
  }

  set favorite(bool fav) {
    this.isFavorite = fav;
    updateCart();
  }

  Future updateCart() async {
    _productDataRef.doc(this.id).set({
      "name": name,
      "price": price,
      "quantity": quantity,
      "favorite": isFavorite
    });
  }

  Future add() async {
    DocumentReference doc = await _productDataRef.add({
      "name": name,
      "price": price,
      "quantity": quantity,
      "favorite": isFavorite
    });

    this.id = doc.id;
  }

  Future remove() async {
    await _productDataRef.doc(this.id).delete();
    this.id = "";
  }

}
