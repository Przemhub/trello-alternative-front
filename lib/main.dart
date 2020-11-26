import 'package:flutter/material.dart';
import 'package:trello_app/home_page.dart';
import 'package:trello_app/login_page.dart';
import 'package:trello_app/register_page.dart';
import 'package:trello_app/tables_page.dart';
import 'package:trello_app/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: Tables(
          user: null,
        ));
  }
}
