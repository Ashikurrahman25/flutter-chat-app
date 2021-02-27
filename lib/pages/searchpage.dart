import 'package:CHEMCHAMP/model/contact.dart';
import 'package:CHEMCHAMP/pages/conversationpage.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:CHEMCHAMP/services/db_service.dart';
import 'package:CHEMCHAMP/services/navigationservices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  double _height;
  double _width;

  SearchPage(this._height, this._width);

  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  AuthProvider _auth;
  String searchText;

  SearchPageState() {
    searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: searchPageUI(),
      ),
    );
  }

  Widget searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              userSearchField(),
              userListView(),
            ],
          ),
        );
      },
    );
  }

  Widget userSearchField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: this.widget._height * 0.02),
      height: this.widget._height * 0.08,
      width: this.widget._width,
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        onSubmitted: (_input) {
          setState(() {
            searchText = _input;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelStyle: TextStyle(color: Colors.white),
          labelText: "Search",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget userListView() {
    return StreamBuilder<List<Contact>>(
        stream: DBService.instance.getUsersInDB(searchText),
        builder: (_context, _snapshot) {
          var usersData = _snapshot.data;
          if (usersData != null) {
            usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
          }

          return _snapshot.hasData
              ? Container(
                  height: this.widget._height * 0.70,
                  child: ListView.builder(
                    itemCount: usersData.length,
                    itemBuilder: (BuildContext _context, int index) {
                      var userData = usersData[index];
                      var currentTime = DateTime.now();
                      var recepientID = usersData[index].id;
                      var isUserActive = !userData.lastSeen.toDate().isBefore(
                            currentTime.subtract(
                              Duration(minutes: 1),
                            ),
                          );
                      return ListTile(
                        onTap: () {
                          DBService.instance.create_getConversation(
                              _auth.user.uid, recepientID,
                              (String _conversationID) {
                            NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (_context) {
                                  return ConversationPage(
                                      _conversationID,
                                      recepientID,
                                      userData.image,
                                      userData.name);
                                },
                              ),
                            );
                          });
                        },
                        title: Text(userData.name),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(userData.image),
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            isUserActive
                                ? Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  )
                                : Text(
                                    "Last seen",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                            isUserActive
                                ? Text(
                                    "Active Now",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  )
                                : Text(
                                    timeago.format(
                                      userData.lastSeen.toDate(),
                                    ),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
        });
  }
}
