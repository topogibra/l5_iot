import 'package:flutter/material.dart';
import 'package:l5_iot/model/user2.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final Function(IconButton?) _setIconButton;
  final Function(FloatingActionButton?) _setFAButton;
  const Profile(
    this._setIconButton,
    this._setFAButton, {
    Key? key,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editProfile = false;

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final UserData? userData = Provider.of<UserData?>(context);

    widget._setFAButton(editProfile
        ? FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: () => {print("Update User")},
          )
        : FloatingActionButton(
            onPressed: () {
              print("Log Out");
            },
            child: Icon(Icons.logout)));

    widget._setIconButton(IconButton(
        onPressed: () => setState(() => {editProfile = !editProfile}),
        icon: Icon(editProfile ? Icons.edit : Icons.edit_outlined)));

    return Container();
  }
}
