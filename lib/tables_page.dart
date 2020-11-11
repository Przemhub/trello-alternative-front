import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trello_app/table.dart';

class Tables extends StatefulWidget {
  @override
  _TablesState createState() => _TablesState();
}

class _TablesState extends State<Tables> {
  List<List<TrelloTable>> tableList = [
    [TrelloTable("first", "image1.jpg")],
    [TrelloTable("second", "img1.jpg")]
  ];
  List<String> teamList = ["private", "team1"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TableList"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: teamList
            .map((team) => SizedBox(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team,
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: tableList[teamList.indexOf(team)]
                                .map((table) => Text(
                                      table.name,
                                      style: TextStyle(fontSize: 12.0),
                                    ))
                                .toList(),
                          ),
                        )
                      ]),
                ))
            .toList(),
      ),
    );
  }
}
