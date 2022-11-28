import 'dart:math';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/helper/helper_functions.dart';
import 'package:group_chat_app_firebase/pages/login_page.dart';
import 'package:group_chat_app_firebase/services/auth_service.dart';

import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthService authService = AuthService();

  register(String fullName, String email, String password) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await AuthService()
          .registerWithEmailAndPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          // Save user data to shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserNameKey(fullName);
          await HelperFunctions.saveUserEmailKey(email);
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
              height: MediaQuery.of(context).size.width * 60 / 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/chat_app_image.png",
                        width: MediaQuery.of(context).size.width * 80 / 100,
                        height: MediaQuery.of(context).size.width * 80 / 100,
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
            ),
            _isLoading
                ? Container(
                    child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ))
                : Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: Column(
                      children: [
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Container(
                                  child: Text(
                                    'Tạo tài khoản',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                ),
                                Container(
                                  child: TextFormField(
                                    autofocus: false,
                                    validator: (value) => value!.isEmpty
                                        ? 'Vui lòng nhập tên người dùng!'
                                        : null,
                                    onSaved: (value) => fullNameController
                                        .text = value.toString(),
                                    controller: fullNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Tên người dùng',
                                      hintStyle: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(
                                        Icons.person,
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
                                        ? 'Vui lòng nhập Email!'
                                        : null,
                                    onSaved: (value) =>
                                        emailController.text = value.toString(),
                                    controller: emailController,
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
                                    onSaved: (value) => passwordController
                                        .text = value.toString(),
                                    controller: passwordController,
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
                                      register(
                                          fullNameController.text,
                                          emailController.text,
                                          passwordController.text);
                                    },
                                    child: Text(
                                      'Đăng ký',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll<Color>(
                                              Colors.orange),
                                    ),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
