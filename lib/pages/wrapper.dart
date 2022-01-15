import 'package:flutter/material.dart';
import 'package:l5_iot/model/user.dart';
import 'package:l5_iot/pages/homepage.dart';
import 'package:l5_iot/pages/loginPage.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
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