import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/group_page.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile(
      {Key? key,
      required this.userName,
      required this.groupId,
      required this.groupName});

  @override
  State<StatefulWidget> createState() {
    return _GroupTileState();
  }
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GroupPage(
              userName: widget.userName,
              groupId: widget.groupId,
              groupName: widget.groupName),
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green,
            child: Text(widget.groupName.substring(0, 1),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          title: Text(
            widget.groupName,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(''),
        ),
      ),
    );
  }
}
