import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/pages/init_page.dart';
import 'package:group_chat_app_firebase/services/auth_service.dart';
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
  var nameController = TextEditingController();
  var uuid = Uuid();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    void showInfoDialog(BuildContext context) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Center(
                child: Text(
                  '🎉Thêm tên người dùng!',
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
                                        height: 60,
                                        child: TextFormField(
                                          autofocus: false,
                                          validator: (value) => value!.isEmpty
                                              ? 'Vui lòng nhập tên người dùng!'
                                              : null,
                                          onSaved: (value) => nameController
                                              .text = value.toString(),
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            hintText: 'Họ và tên',
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
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 90,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              nameController.text = '';
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
                                        Consumer<UserProvider>(
                                          builder: (context, value, child) =>
                                              Container(
                                            width: 90,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                final form =
                                                    formKey.currentState;
                                                if (form!.validate()) {
                                                  value.setUsername(
                                                      nameController.text);
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupPage(
                                                            userId: uuid.v1()),
                                                  ));
                                                  print('Thêm thành công!');
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
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Group Chat App'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text(
                  'Bắt đầu chat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  showInfoDialog(context);
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.orange)),
              ),
              ElevatedButton(
                  onPressed: () {
                    authService.signOut();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InitPage(),
                    ));
                  },
                  child: Text(
                    'Log out',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
