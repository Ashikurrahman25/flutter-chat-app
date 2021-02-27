import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class ConversationSnippet {
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final int unseenCount;
  final Timestamp timestamp;
  final MessageType type;

  ConversationSnippet(
      {this.id,
      this.conversationID,
      this.lastMessage,
      this.name,
      this.image,
      this.timestamp,
      this.unseenCount,
      this.type});

  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data;

    var _messageType = MessageType.Text;

    if (_data["type"] != null) {
      switch (_data["type"]) {
        case "text":
          break;
        case "image":
          _messageType = MessageType.Image;
          break;
        default:
      }
    }

    return ConversationSnippet(
      id: _snapshot.documentID,
      conversationID: _data["conversationID"],
      lastMessage: _data["lastMessage"] != null ? _data["lastMessage"] : "",
      name: _data["name"],
      image: _data["profileImage"],
      unseenCount: _data["unseenCount"],
      timestamp: _data["timestamp"] != null ? _data["timestamp"] : null,
      type: _messageType,
    );
  }
}

class Conversation {
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerID;

  Conversation({this.id, this.members, this.messages, this.ownerID});

  factory Conversation.fromFireestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data;
    List _messages = _data["messages"];
    if (_messages != null) {
      _messages = _messages.map((m) {
        var messageType =
            m["type"] == "text" ? MessageType.Text : MessageType.Image;
        return Message(
            senderID: m['senderID'],
            content: m['message'],
            timestamp: m['timestamp'],
            type: messageType);
      }).toList();
    } else {
      _messages = [];
    }
    return Conversation(
      id: _snapshot.documentID,
      members: _data["members"],
      messages: _messages,
      ownerID: _data["ownerID"],
    );
  }
}
