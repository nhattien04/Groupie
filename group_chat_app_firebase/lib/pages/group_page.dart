import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/msg_model.dart';
import '../providers/user_provider.dart';
import '../services/IP_address_service.dart';
import '../widgets/message_tile.dart';

class GroupPage extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupPage({Key? key, required this.userName, required this.groupId, required this.groupName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GroupPageState();
  }
}

class _GroupPageState extends State<GroupPage> {
  TextEditingController msgController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Stream<QuerySnapshot>? chats;
  String admin = "";


  @override
  void initState() {
    super.initState();
    getChatsAndAdmin();
  }

  getChatsAndAdmin() {
    DatabaseService().getChats(widget.groupId).then((value) => {
      setState(() {
        chats = value;
      })
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((value) => {
      setState(() {
        admin = value;
      })
    });
  }

  chatMessage() {
    return StreamBuilder(
      stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData ? ListView.builder(
            controller: scrollController,
            itemCount: snapshot.data.docs.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.data.docs.length) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 15 / 100,
                  );
                }
                return MessageTile(
                    sender: snapshot.data.docs[index]['sender'],
                    message: snapshot.data.docs[index]['message'],
                    sentByMe: widget.userName == snapshot.data.docs[index]['sender'],
                    time: snapshot.data.docs[index]['time'].toString().substring(10, 16),
                );
              },)
              : Container();
        },);
  }

  sendMessage() {
    if(msgController.text.isNotEmpty) {
      Map<String, dynamic> sendMessageMap = {
        "message": msgController.text,
        "sender": widget.userName,
        "time": DateTime.now().toString()
      };
      DatabaseService().sendMessage(widget.groupId, sendMessageMap);
      setState(() {
        msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFE0E0E0),
      appBar: AppBar(
        leadingWidth: MediaQuery.of(context).size.width * 20 / 100,
        leading: Row(
          children: [
            SizedBox(
              width: 5,
            ),
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text(widget.groupName.substring(0, 1), style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange
                )),
              ),
            ),
          ],
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // width: MediaQuery.of(context).size.width,
              child: Text(
                widget.groupName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.videocam,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                color: Colors.white,
              )),
        ],
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatMessage(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                            child: Card(
                              margin:
                              EdgeInsets.only(left: 2, right: 2, bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                controller: msgController,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.multiline,
                                maxLines: 20,
                                minLines: 1,
                                decoration: InputDecoration(
                                    hintText: 'Nhập tin nhắn...',
                                    prefixIcon: IconButton(
                                      icon: Icon(
                                        Icons.emoji_emotions,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {},
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.attach_file,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            5 /
                                            100),
                                    border: InputBorder.none),
                              ),
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8, right: 5, left: 2),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.orange,
                          child: IconButton(
                            onPressed: () {
                              sendMessage();
                              scrollController.animateTo(
                                  scrollController
                                      .position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            },
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
