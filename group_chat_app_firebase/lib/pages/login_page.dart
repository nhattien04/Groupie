import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/pages/home_page.dart';
import 'package:group_chat_app_firebase/services/auth_service.dart';
import 'package:group_chat_app_firebase/services/database_service.dart';

import '../helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailControllerLogin = TextEditingController();
  final passwordControllerLogin = TextEditingController();
  AuthService authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  login(String email, String password) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await AuthService()
          .loginWithEmailAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingDataUser(email);
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserNameKey(snapshot.docs[0]['fullName']);
          await HelperFunctions.saveUserEmailKey(email);

          var snackBar = SnackBar(
            content: Text(
              'Đăng nhập thành công!',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
        } else {
          setState(() {
            var snackBar = SnackBar(
              content: Text(
                value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/chat_app_image.png",
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        height: MediaQuery.of(context).size.width * 90 / 100,
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: Column(
                      children: [
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Container(
                                  child: TextFormField(
                                    autofocus: false,
                                    validator: (value) => value!.isEmpty
                                        ? 'Vui lòng nhập Email!'
                                        : null,
                                    onSaved: (value) => emailControllerLogin
                                        .text = value.toString(),
                                    controller: emailControllerLogin,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(
                                        Icons.email,
                                        color: Colors.orange,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.orange),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                ),
                                Container(
                                  child: TextFormField(
                                    autofocus: false,
                                    validator: (value) => value!.isEmpty
                                        ? 'Vui lòng nhập mật khẩu!'
                                        : null,
                                    onSaved: (value) => passwordControllerLogin
                                        .text = value.toString(),
                                    controller: passwordControllerLogin,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Mật khẩu',
                                      hintStyle: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(
                                        Icons.info,
                                        color: Colors.orange,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.orange),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      login(emailControllerLogin.text,
                                          passwordControllerLogin.text);
                                    },
                                    child: Text(
                                      'Đăng nhập',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll<Color>(
                                              Colors.green),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
