import 'package:CHEMCHAMP/model/conversation.dart';
import 'package:CHEMCHAMP/model/message.dart';
import 'package:CHEMCHAMP/pages/conversationpage.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:CHEMCHAMP/services/db_service.dart';
import 'package:CHEMCHAMP/services/navigationservices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentConversationPage extends StatelessWidget {
  final double _height;
  final double _width;

  RecentConversationPage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: conversationListView(),
      ),
    );
  }

  Widget conversationListView() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _height,
          width: _width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DBService.instance.getUserConversation(_auth.user.uid),
            builder: (_context, _snapshot) {
              var _data = _snapshot.data;

              if (_data != null) {
                _data.removeWhere((_c) {
                  return _c.timestamp == null;
                });

                return _data.length != 0
                    ? ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (_context, index) {
                          return ListTile(
                            onTap: () {
                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(
                                  builder: (BuildContext _context) {
                                    return ConversationPage(
                                        _data[index].conversationID,
                                        _data[index].id,
                                        _data[index].image,
                                        _data[index].name);
                                  },
                                ),
                              );
                            },
                            title: Text(_data[index].name),
                            subtitle: Text(_data[index].type == MessageType.Text
                                ? _data[index].lastMessage
                                : "Attachment: Image"),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(_data[index].image),
                                ),
                              ),
                            ),
                            trailing: listTileTrailing(_data[index].timestamp),
                          );
                        },
                      )
                    : Align(
                        child: Text(
                          "No conversations",
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 15.0,
                          ),
                        ),
                      );
              } else {
                return SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget listTileTrailing(Timestamp _lastTimeStamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "Last Message",
          style: TextStyle(fontSize: 12),
        ),
        Text(
          timeago.format(
            _lastTimeStamp.toDate(),
          ),
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
