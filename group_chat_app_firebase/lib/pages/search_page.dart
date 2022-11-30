import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/helper/helper_functions.dart';
import 'package:group_chat_app_firebase/pages/group_page.dart';
import 'package:group_chat_app_firebase/services/database_service.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool isJoined = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  User? user;

  initiateSearchMethod() async {
    if(searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      DatabaseService().searchGroup(searchController.text).then((snapshot) => {
        setState(() {
        searchSnapshot = snapshot;
        isLoading = false;
        hasUserSearched = true;
        })
      });
    }
  }

  getCurrentUserAndName() async {
    await HelperFunctions.getUserNameKey().then((value) => {
      setState(() {
        userName = value!;
      })
    });
    user = FirebaseAuth.instance.currentUser;
  }

  groupSearchedItem(String userName, String groupId, String groupName, String admin) {
    joinOrNot(userName, groupId, groupName, admin);
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.green,
        child: Text(groupName.substring(0, 1), style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white
        )),
      ),
      title: Text(groupName, style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black
      ),),
      subtitle: Text('Admin: ${admin.substring(admin.indexOf("_") + 1)}'),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid).toggleGroupJoin(userName, groupId, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            var snackBar = SnackBar(
              content: Text(
                'Đã tham gia nhóm ${groupName}',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                GroupPage(userName: userName, groupId: groupId, groupName: groupName),));
          }
          else {
            setState(() {
              isJoined = !isJoined;
            });
            var snackBar = SnackBar(
              content: Text(
                'Đã rời nhóm ${groupName}',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: isJoined ? Container(
          child: Text('Đã tham gia', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white
          ),),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green
          ),
        ) : Container(
          child: Text('Tham gia', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white
          ),),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.orange
          ),
        ),
      ),
    );
  }

  groupSearchList() {
    return hasUserSearched ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context, index) {
          return groupSearchedItem(
            userName.toString(),
            searchSnapshot!.docs[index]["groupId"],
            searchSnapshot!.docs[index]["groupName"],
            searchSnapshot!.docs[index]["admin"]
          );
        },) : Container();
  }

  joinOrNot(String userName, String groupId, String groupName, String admin) async {
    DatabaseService(uid: user!.uid).isUserJoined(userName, groupId, groupName).then((value) => {
      setState(() {
        isJoined = value;
      })
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserAndName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text('Tìm kiếm nhóm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15),
            child: Card(
              margin:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 2 / 100,
                  right: MediaQuery.of(context).size.width * 2 / 100, bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: TextFormField(
                controller: searchController,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                minLines: 1,
                style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    hintText: 'Nhập tên nhóm...',
                    hintStyle: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            initiateSearchMethod();
                          },
                          icon: Icon(
                            Icons.search,
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
            decoration: BoxDecoration(
                color: Colors.orange[500]
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 2 / 100,),
          isLoading ? Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ) :
          Container(
            child: groupSearchList(),
          ),
        ],
      ),
    );
  }
}