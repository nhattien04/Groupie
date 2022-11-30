import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String sender;
  final String message;
  final bool sentByMe;
  const MessageTile(
      {Key? key,
        required this.sender,
        required this.message,
        required this.sentByMe})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MessageTileState();
  }
}

class _MessageTileState extends State<MessageTile> {
 @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.sentByMe ? Alignment.bottomRight : Alignment.centerLeft,
      child: ConstrainedBox(
          constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 60),
          child: Container(
            margin: widget.sentByMe ? EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 1 / 100, left: MediaQuery.of(context).size.width * 15 / 100, right: MediaQuery.of(context).size.width * 2 / 100) : EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 1 / 100, right: MediaQuery.of(context).size.width * 20 / 100, left: MediaQuery.of(context).size.width * 2 / 100),
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
            decoration: BoxDecoration(
              borderRadius: widget.sentByMe ? BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ) : BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: widget.sentByMe ? Colors.green : Colors.orange,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sender,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.message,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          )
      ),
    );;
  }
}
