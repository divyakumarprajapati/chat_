import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = Firestore.instance;
  final messagetextController = TextEditingController();
  String messageText;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }
//  void getMessages() async{
//    final messages = await _firestore.collection('messages').getDocuments();
//    for (var message in messages.documents){
//      print(message.data);
//    }
//  }
//  void messages_instant() async{
//    await for(var snapshots in _firestore.collection('messages').snapshots()){
//      for (var message in snapshots.documents){
//        print(message.data);
//      }
//    }
//
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(firestore: _firestore),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messagetextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({
    Key key,
    @required Firestore firestore,
  }) : _firestore = firestore, super(key: key);

  final Firestore _firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context,snapshot){
        if (!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
          final messages = snapshot.data.documents.reversed;
          List<Message_Bubble> messagebubble = [];
          for(var message in messages){
            final messageText = message.data['text'];
            final sender_email = message.data['sender'];
            final current_user = loggedInUser.email;

            final message_widget = Message_Bubble(
              sender: sender_email,
              text: messageText,
              isme: current_user == sender_email,
            );
            messagebubble.add(message_widget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              children: messagebubble,
            )
          );
        },
    );
  }
}
class Message_Bubble extends StatelessWidget {
  Message_Bubble({this.text,this.sender,this.isme});
  final String text;
  final String sender;
  final bool isme;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isme?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text('$sender',style: TextStyle(fontSize: 12.0,color: Colors.black54),),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5,
            color: isme?Colors.lightBlueAccent:Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0,),
              child: Text(
                  '$text',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
