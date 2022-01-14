import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l5_iot/auth/auth.dart';

class UserData {
  String name, surname;
  UserData(this.name, this.surname);
}

class UserModel {
  late String _email, _uid, _name, _surname;
  final bool verified;

  final CollectionReference _userDataRef =
      FirebaseFirestore.instance.collection("userData");

  UserModel(this._email, this._uid, this.verified);

  DocumentReference<Object?> _userData() => _userDataRef.doc(this._uid);

  Future update({String? name, String? surname}) async {
    if (name != null || surname != null) {
      await _userData()
          .set({"name": name ?? _name, "surname": surname ?? _surname});

      _name = name ?? _name;
      _surname = surname ?? _surname;
    }
  }

  Future<UserData?> get userData async {
    DocumentSnapshot doc = await _userData().get();
    dynamic data = doc.data();
    if (data != null) return UserData(data["name"], data["surname"]);
    return null;
  }

  Future updateEmail(String nEmail, String password) async {
    await AuthService().updateEmail(email,nEmail,password);
  }

  String get email => _email;
  String get uid => _uid;
}
