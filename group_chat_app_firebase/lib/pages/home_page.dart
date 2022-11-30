import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/helper/helper_functions.dart';
import 'package:group_chat_app_firebase/pages/init_page.dart';
import 'package:group_chat_app_firebase/pages/search_page.dart';
import 'package:group_chat_app_firebase/services/auth_service.dart';
import 'package:group_chat_app_firebase/services/database_service.dart';
import 'package:group_chat_app_firebase/widgets/group_tile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/user_provider.dart';
import 'group_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  var groupNameController = TextEditingController();
  String userName = '';
  String email = '';
  var uuid = Uuid();
  AuthService authService = AuthService();
  Stream? groups;
  Stream? groupInformation;
  Stream? allGroup;
  bool _isLoading = false;
  var recentMessage;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getGroupName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserNameKey().then((value) =>
    {
      setState(() {
        userName = value!;
      })
    });
    await HelperFunctions.getUserEmailKey().then((value) =>
    {
      setState(() {
        email = value!;
      })
    });

    // Get user's list groups
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot) => {
      setState(() {
        groups = snapshot!;
      })
    });
  }

  noGroupList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              showCreateGroupDialog(context);
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75,),
          ),
          SizedBox(height: 30,),
          Center(child: Text('Bạn chưa tham gia nhóm nào!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),)),
          SizedBox(height: 10,),
          Center(child: Text('Nhấn vào biểu tượng để tạo một nhóm mới!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),))
        ],
      ),
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                    itemBuilder: (context, index) {
                    int reverseIndex = snapshot.data['groups'].length - index - 1;

                    return GroupTile(
                        userName: snapshot.data["fullName"],
                        groupId: getGroupId(snapshot.data["groups"][reverseIndex]),
                        groupName: getGroupName(snapshot.data["groups"][reverseIndex]),
                    );
                    },);
              }
              else {
                return noGroupList();
              }
            }
            else {
              return noGroupList();
            }
          }
          else {
            return Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
        });
  }

  showCreateGroupDialog(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Tạo nhóm mới',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        actions: [
          Column(
            children: [
              _isLoading ? Container(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ) :
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                        key: formKey,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 1, right: 1, top: 10),
                                child: Container(
                                  child: TextFormField(
                                    autofocus: false,
                                    validator: (value) => value!.isEmpty
                                        ? 'Vui lòng nhập tên nhóm!'
                                        : null,
                                    onSaved: (value) => groupNameController
                                        .text = value.toString(),
                                    controller: groupNameController,
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 40,
                                    decoration: InputDecoration(
                                      hintText: 'Tên nhóm...',
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 15),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey),
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                    ),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        groupNameController.text = '';
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Hủy',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStatePropertyAll<
                                            Color>(Colors.red),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: 90,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final form =
                                            formKey.currentState;
                                        if (form!.validate()) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupNameController.text).whenComplete(() => {
                                            _isLoading = false
                                          });
                                          Navigator.pop(context);
                                          groupNameController.text = '';
                                          var snackBar = SnackBar(
                                            content: Text(
                                              'Tạo nhóm thành công!',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }
                                      },
                                      child: Text(
                                        'Thêm',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStatePropertyAll<
                                            Color>(Colors.green),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ))
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
              )
            ],
          ),
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Đoạn chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage(),));
          }, icon: Icon(Icons.search)),
        ],

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 50),
          children: [
            InkWell(
              onTap: () {
                showCreateGroupDialog(context);
              },
              child: Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                SizedBox(height: 30,),
                ListTile(
                  onTap: () {},
                  selectedColor: Colors.orange,
                  selected: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Icon(Icons.group),
                  title: Text('Nhóm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),),
                ),
                SizedBox(height: 15,),
                ListTile(
                  onTap: () {},
                  selectedColor: Colors.orange,
                  selected: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Icon(Icons.person, color: Colors.grey,),
                  title: Text('Thông tin tài khoản', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),),
                ),
                SizedBox(height: 15,),
                ListTile(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Đăng xuất tài khoản?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),),
                            content: Text('Bạn có muốn đăng xuất?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),),
                            actions: [
                              IconButton(onPressed: () {
                                Navigator.pop(context);
                              }, icon: Icon(Icons.cancel, color: Colors.red,)),
                              IconButton(onPressed: () async {
                                await authService.signOut();
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => InitPage(),), (route) => false);
                               
                              }, icon: Icon(Icons.done, color: Colors.green,)),
                            ],
                          );
                        });
                  },
                  selectedColor: Colors.orange,
                  selected: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: Icon(Icons.exit_to_app, color: Colors.grey,),
                  title: Text('Đăng xuất', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateGroupDialog(context);
        },
        child: Icon(Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
      ),
      body: groupList(),
    );
  }
}
