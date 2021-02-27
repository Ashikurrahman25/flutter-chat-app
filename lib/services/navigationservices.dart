import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationService {
  static NavigationService instance = new NavigationService();

  GlobalKey<NavigatorState> navKey;

  NavigationService() {
    navKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String pageName) {
    return navKey.currentState.pushReplacementNamed(pageName);
  }

  Future<dynamic> navigateTo(String pageName) {
    return navKey.currentState.pushNamed(pageName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) {
    return navKey.currentState.push(_route);
  }

  bool goBack() {
    navKey.currentState.pop();
  }
}
