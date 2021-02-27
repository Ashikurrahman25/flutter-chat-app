import 'dart:ffi';

import 'package:CHEMCHAMP/services/db_service.dart';
import 'package:CHEMCHAMP/services/navigationservices.dart';
import 'package:CHEMCHAMP/services/snackbar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  FirebaseUser user;
  AuthStatus status;

  FirebaseAuth _auth;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    userAuthentication();
  }

  void autoLogin() async {
    if (user != null) {
      await DBService.instance.updateUserLastSeen(user.uid);
      return NavigationService.instance.navigateToReplacement("home");
    }
  }

  void userAuthentication() async {
    user = await _auth.currentUser();
    if (user != null) {
      notifyListeners();
      await autoLogin();
    }
  }

  void emailpassLogin(String _email, String pass) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _authResult =
          await _auth.signInWithEmailAndPassword(email: _email, password: pass);
      user = _authResult.user;
      status = AuthStatus.Authenticated;
      SnackBarService.instance
          .showSnackBar("Welcome, ${user.email}", Colors.green);

      await DBService.instance.updateUserLastSeen(user.uid);

      NavigationService.instance.navigateToReplacement('home');
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBar("Login failed!", Colors.red);
    }
    notifyListeners();
  }

  void registerUser(String _email, String _password,
      Future<Void> onSuccess(String uId)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement('home');
      SnackBarService.instance
          .showSnackBar("Welcome, ${user.email}", Colors.green);

      await DBService.instance.updateUserLastSeen(user.uid);
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance
          .showSnackBar("Error registering user", Colors.red);
    }

    notifyListeners();
  }

  void logOutUser(Future<void> onSuccess()) async {
    try {
      await DBService.instance.updateUserLastSeen(user.uid);

      await _auth.signOut();
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement("login");
      //user = null;
    } catch (e) {
      SnackBarService.instance.showSnackBar("Logged out failed", Colors.red);
    }
    notifyListeners();
  }
}
