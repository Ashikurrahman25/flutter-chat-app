import 'dart:io';
import 'package:CHEMCHAMP/services/cloudstorageservice.dart';
import 'package:CHEMCHAMP/services/db_service.dart';
import 'package:CHEMCHAMP/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:CHEMCHAMP/services/navigationservices.dart';
import 'package:CHEMCHAMP/services/mediaservice.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegistrationPageState();
  }
}

class RegistrationPageState extends State<RegistrationPage> {
  double _height;
  double _width;

  String _name;
  String _email;
  String _password;

  bool isVisible;
  bool validMail;
  bool passwordGiven;
  bool nameGiven;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  File _image;

  RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
    isVisible = false;
    validMail = false;
    passwordGiven = false;
    nameGiven = false;
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
          child: registrationPageUI(),
        ),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        SnackBarService.instance.buildContext = _context;
        return SingleChildScrollView(
          child: Container(
            height: _height * .75,
            padding: EdgeInsets.symmetric(horizontal: _width * .10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                headingWidget(),
                inputforms(),
                SizedBox(
                  height: 20,
                ),
                registerButton(),
                SizedBox(
                  height: 20,
                ),
                backtoLoginButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget headingWidget() {
    return Container(
      height: _height * 0.10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Start Now!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Join the fun",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          )
        ],
      ),
    );
  }

  Widget inputforms() {
    return Container(
      height: _height * .40,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            imageSelectorWidget(),
            SizedBox(
              height: 20,
            ),
            nameField(),
            SizedBox(
              height: 10,
            ),
            emailfield(),
            SizedBox(
              height: 10,
            ),
            passwordfield(),
          ],
        ),
      ),
    );
  }

  Widget imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File _imageFile = await MediaService.instance.getImage();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _image == null
                  ? Icon(
                      Icons.warning,
                      size: 30,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.check,
                      size: 30,
                      color: Colors.green,
                    ),
            ],
          ),
          height: _height * .15,
          width: _height * .15,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
              image: _image != null
                  ? FileImage(_image)
                  : NetworkImage("https://i.pravatar.cc/150?img=69"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget nameField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      onChanged: (_input) {
        nameGiven = _input.length != 0 ? true : false;
      },
      onSaved: (_input) {
        setState(() {
          _name = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person_outline,
          color: Colors.white,
          size: 18,
        ),
        suffixIcon: nameGiven
            ? Icon(
                Icons.check,
                size: 18,
                color: Colors.green,
              )
            : Icon(
                Icons.warning,
                size: 18,
                color: Colors.red,
              ),
        filled: true,
        hintText: "Name",
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

  Widget emailfield() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      onChanged: (_input) {
        validMail = _input.length != 0 &&
                _input.contains('@') &&
                _input.contains(".com")
            ? true
            : false;
      },
      onSaved: (_input) {
        setState(() {
          _email = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.mail_outline,
          color: Colors.white,
          size: 18,
        ),
        suffixIcon: validMail
            ? Icon(
                Icons.check,
                size: 18,
                color: Colors.green,
              )
            : Icon(
                Icons.warning,
                size: 18,
                color: Colors.red,
              ),
        filled: true,
        hintText: "Email",
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
    return TextFormField(
      autocorrect: false,
      obscureText: !isVisible,
      style: TextStyle(color: Colors.white),
      onChanged: (_input) {
        passwordGiven = _input.length != 0 ? true : false;
      },
      onSaved: (_input) {
        setState(() {
          _password = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.white,
          size: 18,
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min, // added line

            children: <Widget>[
              IconButton(
                onPressed: () {
                  isVisible = !isVisible;
                },
                icon: isVisible
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                iconSize: 18,
                color: Colors.white,
              ),
              passwordGiven
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.warning,
                      size: 18,
                      color: Colors.red,
                    ),
            ],
          ),
        ),
        filled: true,
        hintText: "Password",
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

  Widget registerButton() {
    return _auth.status != AuthStatus.Authenticating
        ? Container(
            height: _height * 0.07,
            width: _width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.blue),
            child: MaterialButton(
              onPressed: () {
                if (validMail && passwordGiven && nameGiven) {
                  if (_image == null) {
                    SnackBarService.instance
                        .showSnackBar("Select an image", Colors.red);
                  } else {
                    _auth.registerUser(
                      _email,
                      _password,
                      (String uID) async {
                        var result = await CloudStorageService.instance
                            .uploadProfilePic(uID, _image);
                        var _imageURL = await result.ref.getDownloadURL();
                        await DBService.instance.addUserDetail(
                            uID, _name, _email, _password, _imageURL);
                      },
                    );
                  }
                }
              },
              child: Center(
                child: Text(
                  "Register",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
        : Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
  }

  Widget backtoLoginButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: Container(
        height: _height * 0.06,
        width: _width,
        child: Icon(
          Icons.arrow_back,
          size: 40,
        ),
      ),
    );
  }
}
