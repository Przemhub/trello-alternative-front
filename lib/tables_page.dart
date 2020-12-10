import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trello_app/home_page.dart';
import 'package:trello_app/login_page.dart';
import 'package:trello_app/table.dart';
import 'package:trello_app/user.dart';
import 'package:http/http.dart' as http;

import 'card.dart';
import 'list.dart';

class TablesPage extends StatefulWidget {
  @override
  _TablesPageState createState() => _TablesPageState();
  User user;
  TablesPage({Key key, @required this.user}) : super(key: key);
}

class _TablesPageState extends State<TablesPage> {
  TrelloTable table;
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
    initLists();
    super.initState();
  }

  static const SERVER_IP = 'https://trello-alternative.herokuapp.com';
  // Future<String> getTableID() async {
  //   var res = await http.get("$SERVER_IP/");
  // }

  getListsByTable(String boardID) async {
    print(boardID);
    print("$SERVER_IP/board/" + boardID);
    var res = await http.get("$SERVER_IP/board/" + boardID, headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    });
    print(res.body);
    if (res.statusCode != 200) {
      print("Error");
    } else {
      var jsonResponse = json.decode(res.body);

      // print("response $jsonResponse");
      for (var list in jsonResponse["board"]["lists"]) {
        print("list $list");
        TrelloList tempList = new TrelloList(list["name"]);
        tempList.id = list["_id"];
        table.lists.add(tempList);
        for (var card in list["cards"]) {
          TrelloCard tempCard = new TrelloCard(card["name"]);
          tempCard.id = card["id"];
          table.lists[table.lists.indexOf(tempList)].cards.add(tempCard);
        }

        // lists["team"] == null means table is private

      }
    }
  }

  renameTable(String boardID, String name) async {
    var res = await http.patch("$SERVER_IP/board/rename", headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    }, body: {
      "board": boardID,
      "name": name
    });
    print(res.statusCode);
    print(res.body);
    if (res.statusCode != 200) {
      print("Error");
    }
  }

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
    user.tableToID[name] = res.body;
    print(name);
    print(res.body);
    if (res.statusCode == 200) return res.body;
    return null;
  }

  TextEditingController _tableTextController = TextEditingController();
  TextEditingController _editTableTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Table List"), actions: [
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                widget.user.clear();
                //implement alert dialog or smth
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              icon: Icon(Icons.settings_power_rounded),
            )),
      ]),
      body: _buildBody(),
    );
  }

  _editTable(int tableIndex, int teamIndex, String tableName) {
    tableList[teamIndex][tableIndex] = tableName;
    // user.tables[teamIndex][tableIndex] = tableName;
    setState(() {});
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

  Widget _buildTable(BuildContext context, String tableName, int teamIndex) {
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
          Text(
            tableName,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(70.0, 25.0, 0.0, 0.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    _showEditTable(
                        tableList[teamIndex].indexOf(tableName), teamIndex);
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
                      Icons.edit_outlined,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                  child: InkWell(
                    onTap: () {
                      table = new TrelloTable(
                          tableName, widget.user.tableToID[tableName]);
                      getListsByTable(widget.user.tableToID[tableName]);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(table, user)));
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
                        Icons.arrow_downward,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          return _buildTable(context, tableList[teamIndex][index], teamIndex);
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

  _showEditTable(int tableIndex, int teamIndex) {
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
                    "Edit Table",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "Table Name"),
                    controller: _editTableTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      String oldName = tableList[teamIndex][tableIndex];
                      Navigator.of(context).pop();
                      _editTable(tableIndex, teamIndex,
                          _editTableTextController.text.trim());
                      renameTable(user.tableToID[oldName],
                          _editTableTextController.text.trim());
                    },
                    child: Text("Edit Table"),
                  ),
                )
              ],
            ),
          );
        });
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
