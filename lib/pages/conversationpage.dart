import 'dart:async';

import 'package:CHEMCHAMP/model/conversation.dart';
import 'package:CHEMCHAMP/model/message.dart';
import 'package:CHEMCHAMP/providers/auth_provider.dart';
import 'package:CHEMCHAMP/services/cloudstorageservice.dart';
import 'package:CHEMCHAMP/services/db_service.dart';
import 'package:CHEMCHAMP/services/mediaservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  String conversationID;
  String receieverID;
  String receieverImage;
  String receieverName;

  ConversationPage(this.conversationID, this.receieverID, this.receieverImage,
      this.receieverName);

  @override
  State<StatefulWidget> createState() {
    return ConversationPageState();
  }
}

class ConversationPageState extends State<ConversationPage> {
  double _height;
  double _width;
  String messageText;

  GlobalKey<FormState> _formKey;
  ScrollController _listViewController;

  ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    messageText = '';
    _listViewController = ScrollController();
  }

  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(this.widget.receieverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: conversationPageUI(),
      ),
    );
  }

  Widget conversationPageUI() {
    return Builder(
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        return Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            messageListView(),
            Align(
                alignment: Alignment.bottomCenter,
                child: messageField(context)),
          ],
        );
      },
    );
  }

  Widget messageListView() {
    return Container(
      height: _height * 0.75,
      width: _width,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(this.widget.conversationID),
        builder: (BuildContext _context, _snapshot) {
          Timer(
            Duration(milliseconds: 50),
            () => {
              if (_listViewController.positions.isNotEmpty)
                {
                  _listViewController
                      .jumpTo(_listViewController.position.maxScrollExtent),
                }
            },
          );

          var conversationData = _snapshot.data;

          if (conversationData != null) {
            if (conversationData.messages.length != 0) {
              return ListView.builder(
                controller: _listViewController,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: conversationData.messages.length,
                itemBuilder: (BuildContext _context, int index) {
                  var message = conversationData.messages[index];
                  bool isOwnMessage = message.senderID == _auth.user.uid;
                  return _messageListViewChild(isOwnMessage, message);
                },
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Text(
                    "Start conversation with, " + this.widget.receieverName),
              );
            }
          } else {
            return SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !isOwnMessage ? userImageWidget() : Container(),
          SizedBox(width: _width * 0.02),
          message.type == MessageType.Text
              ? textMessageBubble(
                  message.content, message.timestamp, isOwnMessage)
              : imageMessageBubble(
                  message.content, message.timestamp, isOwnMessage),
        ],
      ),
    );
  }

  Widget userImageWidget() {
    double imageRadius = _height * 0.05;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(500),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(this.widget.receieverImage),
          )),
    );
  }

  Widget textMessageBubble(
      String _message, Timestamp _timestamp, bool isOwnMessage) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue]
        : [
            Color.fromRGBO(69, 69, 69, 1),
          ];
    return Container(
      height: _height * .08 + (_message.length / 15 * 5.0),
      width: _width * .75,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme[0],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(_message),
          Text(
            timeago.format(
              _timestamp.toDate(),
            ),
            style: TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }

  Widget imageMessageBubble(
      String imageURL, Timestamp _timestamp, bool isOwnMessage) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue]
        : [
            Color.fromRGBO(69, 69, 69, 1),
          ];

    DecorationImage _image =
        DecorationImage(image: NetworkImage(imageURL), fit: BoxFit.cover);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme[0],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: _height * .30,
            width: _width * .40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                  image: NetworkImage(imageURL), fit: BoxFit.cover),
            ),
          ),
          Text(
            timeago.format(
              _timestamp.toDate(),
            ),
            style: TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }

  Widget messageField(BuildContext _context) {
    return Container(
      height: _height * 0.07,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(30),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _height * 0.02, vertical: _width * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            imageMessageButton(),
            messageTextField(),
            sendMessageButton(_context),
          ],
        ),
      ),
    );
  }

  Widget messageTextField() {
    return SizedBox(
      width: _width * 0.6,
      child: TextFormField(
        validator: (_input) {
          if (_input.length == 0) {
            return "Empty message can't be sent";
          }
          return null;
        },
        onChanged: (_input) {
          setMessageText(_input);
        },
        onSaved: (_input) {
          setState(() {
            DBService.instance.updateUserLastSeen(_auth.user.uid);
            messageText = _input;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: "Enter your message here"),
        autocorrect: false,
      ),
    );
  }

  Widget sendMessageButton(BuildContext _context) {
    return Container(
      height: _height * 0.05,
      width: _height * 0.05,
      child: IconButton(
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            DBService.instance.sendMessage(
              this.widget.conversationID,
              Message(
                  content: messageText,
                  timestamp: Timestamp.now(),
                  senderID: _auth.user.uid,
                  type: MessageType.Text),
            );
            _formKey.currentState.reset();
            FocusScope.of(_context).unfocus();
          }
        },
      ),
    );
  }

  Widget imageMessageButton() {
    return Container(
      height: _height * 0.04,
      width: _height * 0.04,
      child: FloatingActionButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImage();
          if (_image != null) {
            var _result = await CloudStorageService.instance
                .mediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              this.widget.conversationID,
              Message(
                  content: _imageURL,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
          }
        },
        child: Icon(
          Icons.camera_enhance,
          size: 20,
        ),
      ),
    );
  }

  void setMessageText(String text) {
    setState(() {
      messageText = text;
    });
  }
}
