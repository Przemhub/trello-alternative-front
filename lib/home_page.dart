import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trello_app/card.dart';
import 'package:trello_app/list.dart';
import 'package:trello_app/table.dart';
import 'package:trello_app/user.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  TrelloTable table;
  User user;
  @override
  _HomePageState createState() => _HomePageState();
  HomePage(this.table, this.user);
}

class _HomePageState extends State<HomePage> {
  List<TrelloList> lists = [];
  @override
  void initState() {
    initTable();
    super.initState();
  }

  initTable() {
    lists = widget.table.lists;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trello Cards"),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: InkWell(
              onTap: () {
                print("Tapped");
                setState(() {});
              },
              child: Icon(Icons.refresh),
            ),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Future<String> postList(String boardId, String name) async {
    var res = await http.post(
      "$SERVER_IP/lists/create",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'board': boardId,
        'name': name,
      },
    );
    if (res.statusCode == 200) return res.body;
    return null;
  }

  Future<String> postCard(String listId, String name) async {
    print("postCard\n");
    print(widget.user.token);
    var res = await http.post(
      "$SERVER_IP/cards/create",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'list': listId,
        'name': name,
      },
    );
    print(listId);
    print(name);
    print(widget.user.token);
    print(res.body);
    print(res.statusCode);
    if (res.statusCode == 200) return res.body;
    return null;
  }

  renameList(String listID) async {
    var res = await http.patch("$SERVER_IP/board/rename" + listID, headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    });
    if (res.statusCode != 200) {
      print("Error");
    } else {
      var jsonResponse = json.decode(res.body);
      print(jsonResponse);
    }
  }

  static const SERVER_IP = 'https://trello-alternative.herokuapp.com';

  // Future<String> postList(String name) async {
  //   var res = await http.post(
  //     "$SERVER_IP/boards/create",
  //     headers: {HttpHeaders.authorizationHeader: userId},
  //     body: {
  //       'board': widget.table.id,
  //       'name': name,
  //     },
  //   );
  //   print(res.body);
  //   if (res.statusCode == 200) return res.body;
  //   return null;
  // }

  // Future<String> postCard(String listName, String cardName) async {
  //   var res = await http.post(
  //     "$SERVER_IP/cards/create",
  //     headers: {HttpHeaders.authorizationHeader: userId},
  //     body: {
  //       'list': widget.table.id,
  //       'name': cardName,
  //     },
  //   );
  //   print(res.body);
  //   if (res.statusCode == 200) return res.body;
  //   return null;
  // }
  TextEditingController _cardTextController = TextEditingController();
  TextEditingController _taskTextController = TextEditingController();
  TextEditingController _editListTextController = TextEditingController();
  TextEditingController _editCardTextController = TextEditingController();

  _editList(int listIndex, String listName) {
    // renameList(listID);
    lists[listIndex].name = listName;
    _editListTextController.clear();
    setState(() {});
  }

  _editCard(int listIndex, int cardIndex, String cardName) {
    lists[listIndex].cards[cardIndex].name = cardName;
    _editCardTextController.clear();
    setState(() {});
  }

  _showEditCard(int listIndex, int cardIndex) {
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
                    "Edit Card",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "Card Name"),
                    controller: _editCardTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _editCard(listIndex, cardIndex,
                          _editCardTextController.text.trim());
                    },
                    child: Text("Edit Card"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _showEditList(int listIndex) {
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
                    "Edit List",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "List Name"),
                    controller: _editListTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _editList(listIndex, _editListTextController.text.trim());
                    },
                    child: Text("Edit List"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _showAddList() {
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
                    "Add List",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "List Title"),
                    controller: _cardTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addList(_cardTextController.text.trim());
                    },
                    child: Text("Add List"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _addList(String text) {
    widget.table.lists.add(TrelloList(text));
    // listNames.add(text);
    // cardNames.add([]);
    _cardTextController.text = "";
    // postList(text);
    postList(widget.table.id, text);
    setState(() {});
  }

  _showAddCard(int index) {
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
                    "Add Card",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "Task Title"),
                    controller: _taskTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addCard(index, _taskTextController.text.trim());
                    },
                    child: Text("Add Card"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _addCard(int index, String text) {
    lists[index].cards.add(TrelloCard(text));
    postCard(lists[index].id, text);
    _taskTextController.text = "";
    setState(() {});
  }

  _handleReOrder(int oldIndex, int newIndex, int index) {
    TrelloCard oldValue = lists[index].cards[oldIndex];
    lists[index].cards[oldIndex] = lists[index].cards[newIndex];
    lists[index].cards[newIndex] = oldValue;
    setState(() {});
  }

  _buildBody() {
    return Stack(
      children: [
        ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: lists.length + 1,
          itemBuilder: (context, index) {
            print(index);
            // print(listNames[index]);
            if (index == lists.length)
              return _buildAddListWidget(context);
            else
              return LongPressDraggable<dynamic>(
                data: {
                  "from": index,
                  "string": lists[index],
                  "child": lists[index].cards
                },
                child: _buildList(context, index),
                feedback: Opacity(
                  child: _buildListDraggable(context, index),
                  opacity: 0.6,
                ),
                childWhenDragging: Container(),
              );
          },
        ),
      ],
    );
  }

  Widget _buildAddListWidget(context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            _showAddList();
          },
          child: Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 2)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add,
                ),
                SizedBox(
                  width: 16.0,
                ),
                Text("Add List"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardWidget(context, index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          _showAddCard(index);
        },
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add,
            ),
            SizedBox(
              width: 16.0,
            ),
            Text("Add Card"),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, int index) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 1)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        lists[index].name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: InkWell(
                          onTap: () {
                            _showEditList(index);
                          },
                          child: Icon(
                            Icons.edit_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: lists[index].cards.length + 1,
                        itemBuilder: (context, index2) {
                          if (index2 == lists[index].cards.length)
                            return _buildAddCardWidget(context, index);
                          else {
                            return _buildCard(index, index2);
                          }
                        }),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: DragTarget<dynamic>(
              onWillAccept: (data) {
                print(data);
                return true;
              },
              onLeave: (data) {},
              onAccept: (data) {
                if (data['from'] == null) {
                  print("index $index data $data");
                  lists[data['from2']].cards.remove(data['string2']);
                  lists[index].cards.add(data['string2']);
                } else if (data['from'] == index) {
                  return;
                } else {
                  lists.remove(data['string']);
                  if (index < lists.length) {
                    lists.insert(index, data['string']);
                    lists[data['string']].cards = data['child'];
                  } else {
                    lists.add(data['string']);
                    lists[data['string']].cards.add(data['child']);
                  }
                }
                print(data);
                setState(() {});
              },
              builder: (context, accept, reject) {
                print("--- > $accept");
                print(reject);
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListDraggable(BuildContext context, int index) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 1)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    lists[index].name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: lists[index].cards.length,
                        itemBuilder: (context, index2) {
                          return _buildCard(index, index2);
                        }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _buildCard(int index, int innerIndex) {
    return Container(
      width: 300.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Draggable<dynamic>(
        feedback: Material(
          elevation: 5.0,
          child: Container(
            width: 284.0,
            padding: const EdgeInsets.all(16.0),
            color: Colors.greenAccent,
            child: SizedBox(
                width: 215.0, child: Text(lists[index].cards[innerIndex].name)),
          ),
        ),
        childWhenDragging: Container(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.greenAccent,
          child: Row(
            children: [
              SizedBox(
                  width: 215.0,
                  child: Text(lists[index].cards[innerIndex].name)),
              Padding(
                padding: const EdgeInsets.fromLTRB(7.0, 0.0, 0.0, 0.0),
                child: InkWell(
                  onTap: () {
                    _showEditCard(index, innerIndex);
                  },
                  child: Icon(
                    Icons.edit_outlined,
                  ),
                ),
              )
            ],
          ),
        ),
        data: {"from2": index, "string2": lists[index].cards[innerIndex]},
      ),
    );
  }
}
