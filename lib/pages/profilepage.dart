import 'package:CHEMCHAMP/model/contact.dart';
import 'package:CHEMCHAMP/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;
  AuthProvider _auth;

  ProfilePage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: profilePageUI(),
      ),
    );
  }

  Widget profilePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (_context, _snapshot) {
            var userData = _snapshot.data;
            return _snapshot.hasData
                ? Align(
                    child: SizedBox(
                      height: _height * .50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          userImageWidget(userData.image),
                          userNameWidget(userData.name),
                          userEmailWidget(userData.email),
                          logOutButton(),
                        ],
                      ),
                    ),
                  )
                : SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: 50.0,
                  );
          },
        );
      },
    );
  }

  Widget userImageWidget(String _image) {
    double _imageRadius = _height * .20;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageRadius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(_image),
        ),
      ),
    );
  }

  Widget userNameWidget(String _userName) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _userName,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget userEmailWidget(String _email) {
    return Container(
      height: _height * 0.03,
      width: _width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget logOutButton() {
    return Container(
      height: _height * 0.07,
      width: _width * .80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.red,
      ),
      child: MaterialButton(
        onPressed: () {
          _auth.logOutUser(() {});
        },
        child: Center(
          child: Text(
            "Log Out",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}