import 'package:firebase_auth/firebase_auth.dart';
import 'package:l5_iot/model/user.dart';

class ErrorMessage {
  String message;
  bool error;
  ErrorMessage({required this.message, required this.error});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebase(User? user, {String? name, String? surname}) {
    return user != null
        ? UserModel(user.email!, user.uid, user.emailVerified)
        : null;
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future<bool> sendVerified() async {
    final User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
      return true;
    }
    return false;
  }

  Future<ErrorMessage> register(
      String name, String surname, String email, String password) async {
    ErrorMessage result = ErrorMessage(message: "", error: false);
    try {
      final UserCredential userCredential = (await _auth
          .createUserWithEmailAndPassword(email: email, password: password));
      _userFromFirebase(userCredential.user)!.update(name: name, surname: surname);
      await sendVerified();
      result.message =
          "Successfully registered $email. Sent verification email.";
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

  Future<ErrorMessage> login(String email, String password) async {
    ErrorMessage errorMessage = ErrorMessage(message: "", error: false);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      bool result = await sendVerified();
      if (result) {
        errorMessage.message =
            "Account not verified. Sent verification email to $email.";
        errorMessage.error = true;
        _auth.signOut();
      } else {
        errorMessage.message = "Logged in successfuly.";
        errorMessage.error = false;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.error = true;
      if (e.code == 'user-not-found') {
        errorMessage.message = 'No user found with that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage.message = 'Wrong password provided for that user.';
      }
    } catch (e) {
      print(e);
    }
    return errorMessage;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
