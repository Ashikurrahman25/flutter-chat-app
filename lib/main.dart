import 'package:CHEMCHAMP/pages/homepage.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:CHEMCHAMP/pages/loginpage.dart';
import 'package:CHEMCHAMP/pages/registrationpage.dart';
import 'package:CHEMCHAMP/services/navigationservices.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Here We Go',
      navigatorKey: NavigationService.instance.navKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        accentColor: Color.fromRGBO(42, 117, 188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "registration": (BuildContext _context) => RegistrationPage(),
        "home": (BuildContext _context) => HomePage(),
      },
    );
  }
}
