import 'package:flutter/material.dart';
import 'package:l5_iot/model/user.dart';
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
  List<String> _labels = ["Name", "Surname", "Email", "uid"];
  late List<String> _changedValues = List.generate(_labels.length, (index) => "");

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    List<String> initValues = ["", "", userModel.email, userModel.uid];

    Widget body = FutureBuilder<UserData?>(
        future: userModel.userData,
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            initValues[0] = snapshot.data!.name;
            initValues[1] = snapshot.data!.surname;
            children = List.generate(
                _labels.length,
                (index) => TextFormField(
                      decoration: InputDecoration(label: Text(_labels[index])),
                      enabled: index == 2 || index == 3 ? false : editProfile,
                      initialValue: initValues[index],
                      onFieldSubmitted: (value) => _changedValues[index] = value,
                      textInputAction: TextInputAction.next,
                    ));
            return Column(children: children);
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Fetching Data...'),
              )
            ];
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children));
          }
        });

    widget._setFAButton(editProfile
        ? FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: () => {print(_changedValues)},
          )
        : FloatingActionButton(
            onPressed: () {
              print("Log Out");
            },
            child: Icon(Icons.logout)));

    widget._setIconButton(IconButton(
        onPressed: () => setState(() => {editProfile = !editProfile}),
        icon: Icon(editProfile ? Icons.edit : Icons.edit_outlined)));

    return Form(
        child: Padding(
      padding: EdgeInsetsDirectional.all(10.0),
      child: body,
    ));
  }
}
