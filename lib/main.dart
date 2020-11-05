import 'dart:html';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/cupertino.dart';
import 'package:trello_app/home_page.dart';
import 'package:flutter_web_ui/ui.dart' as ui;
import 'loading_page.dart';

// void main() => runApp(MyApp());

void main() {
  ui.platformViewRegistry.registerViewFactory(
      'hello-world-html',
          (int viewId) => IFrameElement()
        ..width = '640'
        ..height = '360'
        ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
        ..style.border = 'none');

  runApp(Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      width: 640,
      height: 360,
      child: HtmlElementView(viewType: 'hello-world-html'),
    ),
  ));
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Text("Wassupp boi");
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   debugShowCheckedModeBanner: false,
    //   routes: {
    //     "/": (context)=> Loading(),
    //     "/home": (context) => HomePage(),
    //   }
    // );
  }
}