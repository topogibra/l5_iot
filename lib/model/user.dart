// import 'dart:core';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:l5_iot/auth/auth.dart';

// class UserModel {
//   static late String _name, _surname, _email, _uuid;
//   static final UserModel _singleton = UserModel._internal();

//   static bool _verified = false;
//   static bool _authenticated = false;

//   static String get name => _name;
//   static String get surname => _surname;
//   static String get email => _email;
//   static String get uuid => _uuid;
//   static bool get authenticated => _authenticated;
//   static bool get verified => _verified;

//   factory UserModel() {
//     return _singleton;
//   }

//   static Future<ErrorMessage> register(
//       String name, String surname, String email, String password) async {
//     ErrorMessage result = ErrorMessage(message: "", error: false);
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     try {
//       final UserCredential userCredential = (await auth
//           .createUserWithEmailAndPassword(email: email, password: password));
//       User? user = userCredential.user;
//       await user!.updateDisplayName(name + " " + surname);
//       user = auth.currentUser;
//       update(user!);
//       result.message =
//           "Successfully registered $email. Sent verification email.";
//       await sendVerified();
//     } on FirebaseAuthException catch (e) {
//       result.error = true;
//       if (e.code == "weak-password") {
//         result.message = "Password weak";
//       } else if (e.code == "email-already-in-use") {
//         result.message = "There is an account for this email";
//       }
//     } catch (e) {
//       print(e);
//       await auth.currentUser?.delete();
//     }

//     return result;
//   }

//   static void update(User user) {
//     List<String> userName = user.displayName!.split(" ");
//     _name = userName[0];
//     _surname = userName[1];
//     _email = user.email!;
//     _uuid = user.uid;
//     _verified = user.emailVerified;
//     _authenticated = true;
//   }

//   static Future<void> logout() async {
//     await FirebaseAuth.instance.signOut();
//     reset();
//   }

//   static void updateUser(String name, String surname, String email) {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     auth.currentUser?.updateDisplayName(name + " " + surname);
//     if (_email != email) auth.currentUser?.verifyBeforeUpdateEmail(email);
//   }

//   static Future<ErrorMessage> login(String email, String password) async {
//     ErrorMessage errorMessage = ErrorMessage(message: "", error: false);
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//       bool result = await sendVerified();
//       User? user = userCredential.user;
//       update(user!);
//       _verified = !result;
//       errorMessage.login = _verified;
//       if (result) {
//         errorMessage.message =
//             "Account not verified. Sent verification email to $email.";
//         errorMessage.error = true;
//       } else {
//         errorMessage.message = "Logged in successfuly.";
//         errorMessage.error = false;
//       }
//     } on FirebaseAuthException catch (e) {
//       errorMessage.error = true;
//       if (e.code == 'user-not-found') {
//         errorMessage.message = 'No user found with that email.';
//       } else if (e.code == 'wrong-password') {
//         errorMessage.message = 'Wrong password provided for that user.';
//       }
//     } catch (e) {
//       print(e);
//       reset();
//     }
//     return errorMessage;
//   }

//   static Future<bool> sendVerified() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user != null && !user.emailVerified) {
//       user.sendEmailVerification();
//       return true;
//     }
//     return false;
//   }

//   static reset() {
//     _name = "";
//     _surname = "";
//     _email = "";
//     _uuid = "";
//     _authenticated = false;
//     _verified = false;
//   }

//   UserModel._internal();
// }
