import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trello_app/home_page.dart';
import 'package:trello_app/login_page.dart';
import 'package:trello_app/table.dart';
import 'package:trello_app/user.dart';

class Tables extends StatefulWidget {
  @override
  _TablesState createState() => _TablesState();
  User user;
  Tables({Key key, @required this.user}) : super(key: key);
}

class _TablesState extends State<Tables> {
  List<List<String>> tableList = [
    ["dsa"]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TableList"), actions: [
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
      body: ListView(
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
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: tableList[teamList.indexOf(team)]
                                .map((table) => Container(
                                      margin: EdgeInsets.all(20.0),
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue[200],
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 8,
                                              offset: Offset(0, 0),
                                              color: Color.fromRGBO(
                                                  127, 140, 141, 0.5),
                                              spreadRadius: 2)
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              table,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                60.0, 25.0, 0.0, 0.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HomePage()));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 4,
                                                        offset: Offset(0, 0),
                                                        color: Color.fromRGBO(
                                                            127, 140, 141, 0.5),
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
                                    ))
                                .toList(),
                          ),
                        )
                      ]),
                ))
            .toList(),
      ),
    );
    __buildBody() {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: teamList.length,
        itemBuilder: (context, index) {},
      );
    }

    Widget __buildTableList() {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tableList.length + 1,
        itemBuilder: (context, index) {},
      );
    }

    Widget _buildTable(BuildContext context, String tableName) {
      return Column(
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
      );
    }
  }
}
