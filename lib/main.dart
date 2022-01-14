import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:l5_iot/auth/auth.dart';
import 'package:l5_iot/firebase_options.dart';
import 'package:l5_iot/pages/homepage2.dart';
import 'package:l5_iot/pages/wrapper.dart';
import 'package:provider/provider.dart';

import 'model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        value: AuthService().user,
        initialData: null,
        child: MaterialApp(
          title: 'My Shopping List',
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: Colors.amber,
          ),
          home: Wrapper(),
        ));
  }
}
