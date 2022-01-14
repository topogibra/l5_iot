import 'package:flutter/material.dart';
import 'package:l5_iot/auth/auth.dart';
import 'package:l5_iot/model/user.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final Function(IconButton?) _setIconButton;
  final Function(FloatingActionButton?) _setFAButton;
  final Function() _resetIndex;
  const Profile(
    this._setIconButton,
    this._setFAButton,
    this._resetIndex, {
    Key? key,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editProfile = false;
  List<String> _labels = ["Name", "Surname", "Email", "uid"];
  late List<String> _changedValues =
      List.generate(_labels.length, (index) => "");
  late String password = "";

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
            _changedValues[0] = initValues[0];
            _changedValues[1] = initValues[1];
            children = List.generate(
                _labels.length,
                (index) => TextFormField(
                      decoration: InputDecoration(label: Text(_labels[index])),
                      enabled: index == 3 ? false : editProfile,
                      initialValue: initValues[index],
                      onChanged: (value) => _changedValues[index] = value,
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
            onPressed: () async {
              userModel.update(
                  name: _changedValues[0], surname: _changedValues[1]);
              setState(() {
                editProfile = false;
              });
              //email
              if (_changedValues[2] != "" &&
                  _changedValues[2] != initValues[2]) {
                await showPasswordDialog(context, userModel);
              }
            },
          )
        : FloatingActionButton(
            onPressed: () {
              widget._resetIndex();
              AuthService().signOut();
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

  Future<void> showPasswordDialog(
      BuildContext context, UserModel userModel) async {
    return await showDialog(
        context: context,
        builder: (context) {
          Function() finish = () {
            if (password != "") {
              userModel.updateEmail(_changedValues[2], password);
              password = "";
              Navigator.of(context).pop();
              return showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(seconds: 4), () {
                      widget._resetIndex();
                      Navigator.of(context).pop();
                      AuthService().signOut();
                    });
                    return AlertDialog(
                      content: Text(
                          "You will be signed out in 4 seconds. Please verify your new email."),
                    );
                  });
            }
          };
          return AlertDialog(
            content: Form(
                child: TextFormField(
              onChanged: (value) => password = value,
              onFieldSubmitted: (value) => finish(),
              decoration: InputDecoration(label: Text("Password")),
            )),
            actions: [TextButton(onPressed: finish, child: Text("Submit"))],
          );
        });
  }
}
