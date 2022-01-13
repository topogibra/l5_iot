import 'package:flutter/material.dart';
import 'package:l5_iot/model/user2.dart';
import 'package:l5_iot/pages/homepage.dart';
import 'package:l5_iot/pages/loginPage.dart';
import 'package:l5_iot/pages/registerPage.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserModel?>(context);

    if (user == null) {
      // Not logged in
      return LoginPage();
    } else {
      // Logged in
      return MyHomePage();
    }
  }
}
