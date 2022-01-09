import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';

class ErrorMessage {
  String message;
  bool error;
  ErrorMessage({required this.message, required this.error});
}

class UserModel {
  static late String name, surname, email, uuid;
  static final UserModel _singleton = UserModel._internal();

  static bool authenticated = false;

  factory UserModel() {
    return _singleton;
  }

  static update(String name, String surname, String email, String uuid) {
    UserModel.name = name;
    UserModel.surname = surname;
    UserModel.email = email;
    UserModel.uuid = uuid;
    UserModel.authenticated = true;
  }

  static Future<ErrorMessage> register(
      String name, String surname, String email, String password) async {
    ErrorMessage result = ErrorMessage(message: "", error: false);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final UserCredential userCredential = (await _auth
          .createUserWithEmailAndPassword(email: email, password: password));
      User? user = userCredential.user;
      await user!.updateDisplayName(name + " " + surname);
      user = _auth.currentUser;
      List<String> userName = user!.displayName!.split(" ");
      UserModel.name = userName[0];
      UserModel.surname = userName[1];
      UserModel.email = user.email!;
      UserModel.uuid = user.uid;
      UserModel.authenticated = true;
      result.message = "Successfully registered $email";
    } on FirebaseAuthException catch (e) {
      result.error = true;
      if (e.code == "weak-password") {
        result.message = "Password weak";
      } else if (e.code == "email-already-in-use") {
        result.message = "There is an account for this email";
      }
    } catch (e) {
      print(e);
      await _auth.currentUser?.delete();
    }
    return result;
  }

  static reset() {
    UserModel.name = "";
    UserModel.surname = "";
    UserModel.email = "";
    UserModel.uuid = "";
    UserModel.authenticated = false;
  }

  UserModel._internal();
}
