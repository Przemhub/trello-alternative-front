import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trello_app/home_page.dart';
import 'package:trello_app/login_page.dart';
import 'package:trello_app/table.dart';
import 'package:trello_app/user.dart';
import 'package:http/http.dart' as http;

class Tables extends StatefulWidget {
  @override
  _TablesState createState() => _TablesState();
  User user;
  Tables({Key key, @required this.user}) : super(key: key);
}

class _TablesState extends State<Tables> {
  List<List<String>> tableList = [
    ["random Table"]
  ];
  List<String> teamList = ["private"];
  void initLists() {
    tableList = widget.user.tables;
    teamList = widget.user.teams;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initLists();
  }

  static const SERVER_IP = 'https://trello-alternative.herokuapp.com';

  Future<String> postTable(String userId, String name, String team) async {
    var res = await http.post(
      "$SERVER_IP/boards/create",
      headers: {HttpHeaders.authorizationHeader: userId},
      body: {
        'name': name,
        'team': team,
        'visibility': 'private',
        'background': 'blue'
      },
    );
    print(name);
    print(res.body);
    if (res.statusCode == 200) return res.body;
    return null;
  }

  TextEditingController _tableTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Table List"), actions: [
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                widget.user.clear();
                // AlertDialog(
                //   title: Text("My title"),
                //   content: Text("This is my message."),
                //   actions: [],
                // );
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              icon: Icon(Icons.settings_power_rounded),
            )),
      ]),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return ListView(
      scrollDirection: Axis.vertical,
      children: teamList
          .map((team) => SizedBox(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          team,
                          style: TextStyle(
                              fontSize: 20.0, fontStyle: FontStyle.italic),
                        ),
                      ),
                      SizedBox(
                        height: 120,
                        child: _buildTableList(context, teamList.indexOf(team)),
                      )
                    ]),
              ))
          .toList(),
    );
  }

  Widget _buildTable(BuildContext context, String tableName) {
    return Container(
      margin: EdgeInsets.all(20.0),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.lightBlue[200],
        boxShadow: [
          BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 0),
              color: Color.fromRGBO(127, 140, 141, 0.5),
              spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            child: Text(
              tableName,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(60.0, 25.0, 0.0, 0.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        offset: Offset(0, 0),
                        color: Color.fromRGBO(127, 140, 141, 0.5),
                        spreadRadius: 3)
                  ],
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.arrow_circle_down,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableList(BuildContext context, int teamIndex) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tableList[teamIndex].length + 1,
      itemBuilder: (context, index) {
        if (index < tableList[teamIndex].length) {
          return _buildTable(context, tableList[teamIndex][index]);
        } else {
          return _buildTableAddWidget(context, teamIndex);
        }
      },
    );
  }

  _addTable(String name, int index) {
    _tableTextController.text = "";
    user.tables[index].add(name);
    postTable(user.token, name, teamList[index]);
    setState(() {});
  }

  _showAddTable(int teamIndex) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Add Table",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "Table Title"),
                    controller: _tableTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addTable(_tableTextController.text.trim(), teamIndex);
                    },
                    child: Text("Add Table"),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildTableAddWidget(BuildContext context, int teamIndex) {
    return Container(
      margin: EdgeInsets.all(20.0),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.lightBlue[200],
        boxShadow: [
          BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 0),
              color: Color.fromRGBO(127, 140, 141, 0.5),
              spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            child: Text(
              "Add Table",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(60.0, 25.0, 0.0, 0.0),
            child: InkWell(
              onTap: () {
                _showAddTable(teamIndex);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        offset: Offset(0, 0),
                        color: Color.fromRGBO(127, 140, 141, 0.5),
                        spreadRadius: 3)
                  ],
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.add,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
