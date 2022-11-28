import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app_firebase/helper/helper_functions.dart';
import 'package:group_chat_app_firebase/pages/home_page.dart';
import 'package:group_chat_app_firebase/pages/init_page.dart';
import 'package:group_chat_app_firebase/pages/login_page.dart';
import 'package:group_chat_app_firebase/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GroupChatAppWithFirebase(),
    ),
  );
}

class GroupChatAppWithFirebase extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GroupChatAppWithFirebase();
  }
}

class _GroupChatAppWithFirebase extends State<GroupChatAppWithFirebase> {
  bool _isSignedIn = false;

  getUserLoggedInStatus() async {
    await HelperFunctions.getLoggedInStatus().then((value) => {
          if (value != null)
            {
              setState(() {
                _isSignedIn = value;
              })
            }
        });
  }

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
      home: Scaffold(
        body: SafeArea(
          child: _isSignedIn ? HomePage() : InitPage(),
        ),
      ),
    );
  }
}
