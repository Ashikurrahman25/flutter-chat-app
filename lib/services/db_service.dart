import 'package:CHEMCHAMP/model/contact.dart';
import 'package:CHEMCHAMP/model/conversation.dart';
import 'package:CHEMCHAMP/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static DBService instance = new DBService();

  Firestore _db;

  DBService() {
    _db = Firestore.instance;
  }

  String userCollection = "Users";
  String conversationCollection = "Conversations";

  Future<void> addUserDetail(String _uID, String _name, String _email,
      String _password, String _imageURL) async {
    try {
      await _db.collection(userCollection).document(_uID).setData({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      print("error!");
    }
  }

  Future<void> updateUserLastSeen(String _userID) {
    
     var _ref = _db.collection(userCollection).document(_userID);
     return _ref.updateData({
       "lastSeen": Timestamp.now(),
     });
  }

  Future<void> sendMessage(String _conversationID, Message _message) {
    var _ref = _db.collection(conversationCollection).document(_conversationID);
    var _messageType = "";

    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;

      case MessageType.Image:
        _messageType = "image";
        break;

      default:
    }

    return _ref.updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            'message': _message.content,
            'senderID': _message.senderID,
            'timestamp': _message.timestamp,
            'type': _messageType,
          },
        ],
      )
    });
  }

  Future<void> create_getConversation(String currentID, String recepientID,
      Future<void> onSuccess(String _conversationID)) async {
    var _ref = _db.collection(conversationCollection);
    var _userConversation = _db
        .collection(userCollection)
        .document(currentID)
        .collection(conversationCollection);

    try {
      var conversation = await _userConversation.document(recepientID).get();

      if (conversation.data != null) {
        return onSuccess(conversation.data["conversationID"]);
      } else {
        var _conversationRef = _ref.document();
        await _conversationRef.setData({
          "members": [
            currentID,
            recepientID,
          ],
          "ownerID": currentID,
          "messages": [],
        });

        return onSuccess(_conversationRef.documentID);
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<Contact> getUserData(String userID) {
    var _ref = _db.collection(userCollection).document(userID);
    return _ref.get().asStream().map(
      (_snapshot) {
        return Contact.fromFirestore(_snapshot);
      },
    );
  }

  Stream<List<ConversationSnippet>> getUserConversation(String userID) {
    var _ref = _db
        .collection(userCollection)
        .document(userID)
        .collection(conversationCollection);
    return _ref.snapshots().map(
      (_snapshot) {
        return _snapshot.documents.map(
          (_doc) {
            return ConversationSnippet.fromFirestore(_doc);
          },
        ).toList();
      },
    );
  }

  Stream<List<Contact>> getUsersInDB(String _searchUser) {
    var _ref = _db
        .collection(userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchUser)
        .where("name", isLessThan: _searchUser + 'z');

    return _ref.getDocuments().asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    var _ref = _db.collection(conversationCollection).document(conversationID);
    return _ref.snapshots().map((_snapshot) {
      return Conversation.fromFireestore(_snapshot);
    });
  }
}
