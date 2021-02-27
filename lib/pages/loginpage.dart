import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:CHEMCHAMP/services/snackbar_service.dart';
import 'package:CHEMCHAMP/services/navigationservices.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  double _height;
  double _width;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;
  String _email;
  String pass;
  bool isVisible;

  LoginPageState() {
    _formKey = GlobalKey<FormState>();
    isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _loginPageUI(),
        ),
      ),
    );
  }

  Widget _loginPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        print(_auth.user);
        return Container(
          height: _height * 0.60,
          padding: EdgeInsets.symmetric(horizontal: _width * 0.10),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headingWidget(),
              SizedBox(
                height: 50,
              ),
              inputforms(),
              SizedBox(
                height: 15,
              ),
              loginButton(),
              SizedBox(
                height: 10,
              ),
              registerButton(),
            ],
          ),
        );
      },
    );
  }

  Widget headingWidget() {
    return Container(
      height: _height * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Welcome Back!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Login to continue",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          )
        ],
      ),
    );
  }

  Widget inputforms() {
    return Container(
      child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState.save();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                emailfield(),
                SizedBox(height: 10),
                passwordfield(),
              ],
            ),
          )),
    );
  }

  Widget emailfield() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      // validator: (_input) {
      //   return _input.length != 0 && _input.contains('@') ? null : "";
      // },
      onSaved: (_input) {
        setState(() {
          _email = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: (Icon(
          Icons.mail_outline,
          color: Colors.white,
          size: 18,
        )),
        labelText: "Email",
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget passwordfield() {
    print(isVisible);
    return TextFormField(
      autocorrect: false,
      obscureText: !isVisible,
      style: TextStyle(color: Colors.white),
      // validator: (_input) {
      //   return _input.length != 0 ? null : "Password field can't be empty";
      // },
      onSaved: (_input) {
        setState(() {
          pass = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: (Icon(
          Icons.lock_outline,
          color: Colors.white,
          size: 18,
        )),
        suffixIcon: IconButton(
          onPressed: () {
            isVisible = !isVisible;
          },
          icon: isVisible ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
          iconSize: 18,
          color: Colors.white,
        ),
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : Container(
            height: _height * 0.06,
            width: _width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue,
            ),
            child: MaterialButton(
              onPressed: () {
                _auth.emailpassLogin(_email, pass);
              },
              child: Center(
                child: Text(
                  "Log In",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          );
  }

  Widget registerButton() {
    return Container(
      height: _height * 0.06,
      width: _width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white60)),
      child: MaterialButton(
        onPressed: () {
          NavigationService.instance.navigateTo('registration');
        },
        child: Center(
          child: Text(
            "Register",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white60),
          ),
        ),
      ),
    );
  }
}
