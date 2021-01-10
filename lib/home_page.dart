import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:trello_app/card.dart';
import 'package:trello_app/list.dart';
import 'package:trello_app/table.dart';
import 'package:trello_app/user.dart';
import 'package:table_calendar/table_calendar.dart';
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
  List<TrelloCard> archivedCards = [];
  List<TrelloList> archivedLists = [];
  List<String> members = [];
  User user;
  static const SERVER_IP = 'https://trello-alternative.herokuapp.com';

  TextEditingController _cardTextController = TextEditingController();
  TextEditingController _taskTextController = TextEditingController();
  TextEditingController _editListTextController = TextEditingController();
  TextEditingController _editCardTextController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _hourController = TextEditingController();
  TextEditingController _minuteController = TextEditingController();
  TextEditingController _userTextController = TextEditingController();

  CalendarController _calendarController = CalendarController();

  bool description_enabled = false;

  @override
  void initState() {
    initTable();
    super.initState();
  }

  initTable() {
    lists = widget.table.lists;
    archivedCards = widget.table.archivedCards;
    archivedLists = widget.table.archivedLists;
    members = widget.table.members;
    setState(() => this.lists);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            child: Row(children: [
              Text(
                'Menu',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(150, 0, 0, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
            ]),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Zarchiwizowane'),
            hoverColor: Colors.blueGrey[200],
            onTap: () {
              _showArchivedCardsDialog();
            },
          ),
          ListTile(
            title: Text('Użytkownicy'),
            hoverColor: Colors.blueGrey[200],
            onTap: () {
              _showUsersDialog();
            },
          ),
        ]),
      ),
      appBar: AppBar(
        title: Text("Trello Cards"),
      ),
      body: _buildBody(),
    );
  }

  deleteDeadline(String cardId) async {
    var res = await http.patch(
      "$SERVER_IP/cards/",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {},
    );
    print(res.statusCode);
    print(res.body);
  }

  postActivity(String cardId, String activity) async {
    var res = await http.post(
      "$SERVER_IP/cards/",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {},
    );
  }

  postListDisplacement() async {
    List<String> ListsIDs = widget.table.lists.map((list) => list.id).toList();
    String jsonIdLists = jsonEncode(ListsIDs);
    var body = {"board": widget.table.id, "lists": jsonIdLists};

    var res = await http.post(
      "$SERVER_IP/lists/reorder",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: body,
    );
    // print("board " + widget.table.id + "  lists " + jsonIdLists);
    // print("json encoded msg $jsonIdLists");
    print("list displacement");
    print(body);
    print(widget.table.id);
    print(res.body);
    print(res.statusCode);
  }

  updateCardArchivation(String cardId) async {
    var res = await http.patch(
      "$SERVER_IP/cards/archive",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'card': cardId,
      },
    );
    setState(() {});
    print(res.statusCode);
    print(res.body);
  }

  unarchiveCard(String cardId) async {
    var res = await http.patch(
      "$SERVER_IP/cards/unarchive",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'card': cardId,
      },
    );
    setState(() {});
    print(res.statusCode);
    print(res.body);
  }

  updateListArchivation(String listId) async {
    var res = await http.patch(
      "$SERVER_IP/lists/archive",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'list': listId,
      },
    );
    print(res.statusCode);
    print(res.body);
  }

  unarchiveList(String listId) async {
    var res = await http.patch(
      "$SERVER_IP/lists/unarchive",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'list': listId,
      },
    );

    print(res.statusCode);
    print(res.body);
  }

  deleteCard(String cardId) async {
    var res = await http.post("$SERVER_IP/cards/remove", headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    }, body: {
      "card": cardId
    });
    print(res.statusCode);
    print(res.body);
  }

  deleteList(String listId) async {
    var res = await http.post("$SERVER_IP/lists/remove", headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    }, body: {
      "list": listId
    });
    print(res.statusCode);
    print(res.body);
  }

  postMember(String email, boardId) async {
    var res = await http.post(
      "$SERVER_IP/board/adduser",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {"user": email, "board": boardId},
    );
    print("post Member");
    print(res.statusCode);
    print(res.body);
  }

  updateDescription(String cardId, String description) async {
    print("cardId $cardId");
    print("cardId $cardId");
    var res = await http.patch(
      "$SERVER_IP/cards/description",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'card': cardId,
        'description': description,
      },
    );
    print("Update descr");
    print(res.statusCode);
    print(res.body);
  }

  updateDeadline(String cardId, String deadline) async {
    await http.patch(
      "$SERVER_IP/cards/deadline",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'card': cardId,
        'deadline': deadline,
      },
    );
  }

  postList(String boardId, String name) async {
    await http.post(
      "$SERVER_IP/lists/create",
      headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.user.token},
      body: {
        'board': boardId,
        'name': name,
      },
    );
  }

  postCard(String listId, String name) async {
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

  renameList(String listID, String listName) async {
    var res = await http.patch("$SERVER_IP/lists/rename", headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    }, body: {
      "list": listID,
      "name": listName
    });
    if (res.statusCode != 200) {
      print("Error");
    }
  }

  renameCard(String cardID, String cardName) async {
    print(cardID);
    print(cardName);
    var res = await http.patch("$SERVER_IP/cards/rename", headers: {
      HttpHeaders.authorizationHeader: "Bearer " + widget.user.token
    }, body: {
      "card": cardID,
      "name": cardName
    });
    if (res.statusCode != 200) {
      print("Error");
    }
  }

  _editList(int listIndex, String listName) {
    lists[listIndex].name = listName;
    _editListTextController.clear();
    renameList(widget.table.lists[listIndex].id, listName);
    setState(() {});
  }

  _editCard(int listIndex, int cardIndex, String cardName) {
    lists[listIndex].cards[cardIndex].name = cardName;
    _editCardTextController.clear();
    renameCard(lists[listIndex].cards[cardIndex].id, cardName);
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
                    key: Key("EditCard"),
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
                    "Edytuj Listę",
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
                    key: Key("EditList"),
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
                    "Dodaj Listę",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "Nazwa Listy"),
                    controller: _cardTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    key: Key("AddList"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addList(_cardTextController.text.trim());
                    },
                    child: Text("Dodaj Listę"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _addList(String text) {
    widget.table.lists.add(TrelloList(text));
    _cardTextController.text = "";
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
                    "Dodaj Kartę",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: "Nazwa Karty"),
                    controller: _taskTextController,
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                Center(
                  child: RaisedButton(
                    key: Key("AddCard"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addCard(index, _taskTextController.text.trim());
                    },
                    child: Text("Dodaj Kartę"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _addCard(int index, String text) {
    TrelloCard newCard = TrelloCard(text);
    newCard.id = postCard(lists[index].id, text).toString();
    newCard.parentName = lists[index].name;
    newCard.activities
        .add(widget.user.name + " dodał kartę do " + newCard.parentName);
    lists[index].cards.add(newCard);
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
          key: Key("listview"),
          scrollDirection: Axis.horizontal,
          itemCount: lists.length + 1,
          itemBuilder: (context, index) {
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
                Text("Dodaj Listę"),
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
            Text("Dodaj Kartę"),
          ],
        ),
      ),
    );
  }

  _showArchivedListsDialog() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 0),
                        color: Color.fromRGBO(127, 140, 141, 0.5),
                        spreadRadius: 2)
                  ],
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                width: 400,
                height: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(370, 5, 0, 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.clear,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(90, 0, 0, 0),
                      child: Text(
                        "Zarchiwizowane listy",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showArchivedCardsDialog();
                        },
                        child: Text("Przełącz na karty"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      height: 440,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: archivedLists.length,
                          itemBuilder: (context, index) {
                            return _buildArchivedList(archivedLists[index]);
                          }),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget _buildArchivedList(TrelloList archivedList) {
    return Column(children: [
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
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
          child: Row(
            children: [
              SizedBox(width: 215.0, child: Text(archivedList.name)),
            ],
          ),
        ),
      ),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 10, 0, 0),
            child: RaisedButton(
                child: Text("Odzyskaj"),
                onPressed: () {
                  archivedLists.remove(archivedList);
                  lists.add(archivedList);
                  unarchiveList(archivedList.id);
                  Navigator.of(context).pop();
                  _showArchivedListsDialog();
                  setState(() {});
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
            child: RaisedButton(
                child: Text("Usuń"),
                onPressed: () {
                  archivedLists.remove(archivedList);
                  deleteList(archivedList.id);
                  Navigator.of(context).pop();
                  _showArchivedCardsDialog();
                }),
          )
        ],
      )
    ]);
  }

  Widget _buildArchivedCard(TrelloCard archivedCard) {
    return Column(children: [
      Container(
        width: 300.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.greenAccent,
          child: Row(
            children: [
              SizedBox(width: 215.0, child: Text(archivedCard.name)),
            ],
          ),
        ),
      ),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 10, 0, 0),
            child: RaisedButton(
                child: Text("Odzyskaj"),
                onPressed: () {
                  TrelloList tempList;
                  for (TrelloList list in lists) {
                    if (list.name == archivedCard.parentName) {
                      tempList = list;
                    }
                  }
                  if (tempList == null) {
                    displayDialog(
                        context,
                        "Rodzic nie istnieje",
                        "Lista " +
                            archivedCard.parentName +
                            ", do której należy karta zostałą usunięta lub zarchiwizowana.");
                  } else {
                    archivedCard.activities
                        .add(widget.user.name + " odzyskał kartę do tablicy");
                    archivedCards.remove(archivedCard);
                    lists[lists.indexOf(tempList)].cards.add(archivedCard);
                    unarchiveCard(archivedCard.id);

                    Navigator.of(context).pop();
                    _showArchivedCardsDialog();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 0, 0),
            child: RaisedButton(
                child: Text("Usuń"),
                onPressed: () {
                  archivedCards.remove(archivedCard);
                  deleteCard(archivedCard.id);
                  Navigator.of(context).pop();
                  _showArchivedCardsDialog();
                }),
          )
        ],
      )
    ]);
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
                            _showListOptionsDialog(index);
                          },
                          child: Icon(
                            Icons.keyboard_control,
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
                //moving cards
                if (data['from'] == null) {
                  // print("index $index data $data");
                  lists[data['from2']].cards.remove(data['string2']);
                  lists[index].cards.add(data['string2']);
                  // postActivity(
                  //     lists[index].cards.last.id,
                  //     widget.user.name +
                  //         " przeniósł kartę do " +
                  //         lists[index].name);
                  lists[index].cards.last.activities.add(widget.user.name +
                      " przeniósł kartę do " +
                      lists[index].name);
                } else if (data['from'] == index) {
                  return;
                } else {
                  lists.remove(data['string']);
                  if (index < lists.length) {
                    lists.insert(index, data['string']);
                    lists[lists.indexOf(data['string'])].cards = data['child'];
                  } else {
                    lists.add(data['string']);
                    lists[lists.indexOf(data['string'])].cards =
                        (data['child']);
                  }
                  postListDisplacement();
                }
                // print(data);
                setState(() {});
              },
              builder: (context, accept, reject) {
                // print("--- > $accept");
                // print(reject);
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
                      child: Container()),
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
                width: 215.0,
                child: Row(
                  children: [
                    Text(lists[index].cards[innerIndex].name),
                  ],
                )),
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
                    _showCardDialog(index, innerIndex,
                        lists[index].cards[innerIndex].deadline);
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

  _showCardDialog(int index, int innerIndex, String deadline) {
    if (lists[index].cards[innerIndex].description != null) {
      _descriptionController.text = lists[index].cards[innerIndex].description;
    } else {
      _descriptionController.text = "";
    }
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            child: Container(
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
              width: 650,
              height: 582,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lists[index].cards[innerIndex].name,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: InkWell(
                            child: Icon(Icons.edit_outlined),
                            onTap: () {
                              _showEditCard(index, innerIndex);
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                            child: Text(
                              "Termin:  " + deadline,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: deadline.length < 6
                              ? null
                              : () {
                                  lists[index]
                                      .cards[innerIndex]
                                      .activities
                                      .add(widget.user.name + " usunął termin");
                                  // postActivity(lists[index].cards[innerIndex].id,
                                  //     widget.user.name + " usunął termin");
                                  lists[index].cards[innerIndex].deadline =
                                      "brak";
                                  Navigator.of(context).pop();
                                  _showCardDialog(index, innerIndex, deadline);
                                  //usuwanie terminu po stronie serwera
                                },
                          child: Icon(Icons.clear),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                            width: 450,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            height: 440,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Opis",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(width: 30),
                                    RaisedButton(
                                        key: Key("Edit"),
                                        disabledColor: Colors.grey[800],
                                        onPressed: description_enabled
                                            ? null
                                            : () {
                                                Navigator.of(context).pop();
                                                setState(() =>
                                                    description_enabled = true);
                                                _showCardDialog(index,
                                                    innerIndex, deadline);
                                              },
                                        child: Row(children: [
                                          Icon(Icons.edit_outlined),
                                          Text("Edytuj")
                                        ])),
                                  ],
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: "Wpisz opis",
                                  ),
                                  enabled: description_enabled,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
                                  controller: _descriptionController,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        key: Key("submit"),
                                        onPressed: () {
                                          String description =
                                              _descriptionController.text;
                                          lists[index]
                                              .cards[innerIndex]
                                              .description = description;
                                          updateDescription(
                                              lists[index].cards[innerIndex].id,
                                              description);
                                          Navigator.of(context).pop();
                                          setState(() =>
                                              description_enabled = false);
                                          _showCardDialog(
                                              index, innerIndex, deadline);
                                        },
                                        child: Text("Wyślij Opis"),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 0.0, 10.0),
                                  child: Text(
                                    "Aktywność",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: lists[index]
                                        .cards[innerIndex]
                                        .activities
                                        .length,
                                    itemBuilder: (context, int activityIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0.0, 10.0, 0.0, 0.0),
                                        child: Text(lists[index]
                                            .cards[innerIndex]
                                            .activities[activityIndex]),
                                      );
                                    },
                                  ),
                                )
                              ],
                            )),
                        Container(
                          width: 150,
                          height: 450,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 0.0),
                                child: Text("Dodaj do karty",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: RaisedButton(
                                  key: Key("termin"),
                                  onPressed: () {
                                    print("Termin");
                                    showDialog(
                                        context: context,
                                        child: Dialog(
                                            child: Container(
                                          height: 740,
                                          width: 700,
                                          child: Column(
                                            children: [
                                              TableCalendar(
                                                // locale: "pl_PL",
                                                calendarController:
                                                    _calendarController,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                        fontSize: 35,
                                                      ),
                                                      controller:
                                                          _hourController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: "godz",
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            8.0, 0, 8.0, 0),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                          fontSize: 40),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextFormField(
                                                      style: TextStyle(
                                                          fontSize: 35),
                                                      controller:
                                                          _minuteController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: "min",
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 10, 0, 0),
                                                    child: RaisedButton(
                                                        color:
                                                            Colors.indigo[600],
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0)),
                                                        child: SizedBox(
                                                          width: 85,
                                                          height: 50,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Text("Ustaw",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          int day =
                                                              _calendarController
                                                                  .selectedDay
                                                                  .day;
                                                          int month =
                                                              _calendarController
                                                                  .selectedDay
                                                                  .month;
                                                          int year =
                                                              _calendarController
                                                                  .selectedDay
                                                                  .year;
                                                          int hour = 12;
                                                          int minute = 00;
                                                          bool correct = true;
                                                          if (_hourController
                                                              .text
                                                              .isNotEmpty) {
                                                            hour = int.parse(
                                                                _hourController
                                                                    .text);

                                                            correct =
                                                                hour < 25 &&
                                                                    hour > 0;
                                                            correct =
                                                                hour != null;
                                                            correct = false;
                                                          }
                                                          if (_minuteController
                                                              .text
                                                              .isNotEmpty) {
                                                            minute = int.parse(
                                                                _minuteController
                                                                    .text);
                                                            correct =
                                                                minute != null;
                                                            correct =
                                                                minute < 60 &&
                                                                    minute > -1;
                                                          }
                                                          if (correct == true) {
                                                            lists[index]
                                                                    .cards[
                                                                        innerIndex]
                                                                    .deadline =
                                                                "$year-$month-$day $hour:$minute";
                                                            updateDeadline(
                                                                lists[index]
                                                                    .cards[
                                                                        innerIndex]
                                                                    .id,
                                                                lists[index]
                                                                    .cards[
                                                                        innerIndex]
                                                                    .deadline);
                                                            _hourController
                                                                .clear();
                                                            _minuteController
                                                                .clear();
                                                            _calendarController
                                                                .dispose();
                                                            lists[index]
                                                                .cards[
                                                                    innerIndex]
                                                                .activities
                                                                .add(widget.user
                                                                        .name +
                                                                    " dodał termin do karty");
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } else {
                                                            displayDialog(
                                                                context,
                                                                "Błędna godzina",
                                                                "Wprowadź poprawnie godzinę");
                                                          }
                                                        }),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )));
                                  },
                                  color: Colors.lightBlue[400],
                                  hoverColor: Colors.lightBlue[200],
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today),
                                      Text("Termin")
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              Text("Działania",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: RaisedButton(
                                  key: Key("Archive"),
                                  onPressed: () {
                                    TrelloCard archCard =
                                        lists[index].cards.removeAt(innerIndex);
                                    // postActivity(
                                    //     archCard.id,
                                    //     widget.user.name +
                                    //         " zarchiwizował kartę");
                                    archCard.activities.add(widget.user.name +
                                        " zarchiwizował kartę");
                                    archivedCards.add(archCard);
                                    updateCardArchivation(archCard.id);
                                    Navigator.of(context).pop();
                                  },
                                  color: Colors.lightBlue[400],
                                  hoverColor: Colors.lightBlue[200],
                                  child: Row(
                                    children: [
                                      Icon(Icons.archive),
                                      Text("Zarchiwizuj")
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _showListOptionsDialog(int listIndex) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 0),
                        color: Color.fromRGBO(127, 140, 141, 0.5),
                        spreadRadius: 2)
                  ],
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                width: 150,
                height: 200,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(220, 5, 0, 0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.clear,
                          size: 28,
                        ),
                      ),
                    ),
                    ListTile(
                      hoverColor: Colors.blueGrey[200],
                      title: Text("Zmień nazwę"),
                      onTap: () {
                        _showEditList(listIndex);
                      },
                    ),
                    ListTile(
                      hoverColor: Colors.blueGrey[200],
                      title: Text("Zarchiwizuj"),
                      onTap: () {
                        TrelloList archList = lists.removeAt(listIndex);

                        updateListArchivation(archList.id);
                        archivedLists.add(archList);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                    ),
                    ListTile(
                      hoverColor: Colors.blueGrey[200],
                      title: Text("Zarchiwizuj wszystkie karty"),
                      onTap: () {
                        archivedCards.addAll(lists[listIndex].cards);
                        for (TrelloCard card in lists[listIndex].cards) {
                          updateCardArchivation(card.id);
                        }
                        lists[listIndex].cards.clear();
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ));
  }

  _showUsersDialog() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 0),
                        color: Color.fromRGBO(127, 140, 141, 0.5),
                        spreadRadius: 2)
                  ],
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                width: 320,
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(270, 5, 0, 20),
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.clear,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Text(
                          "Lista Użytkowników",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      Container(
                        height: 210,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              return _buildUserElement(index);
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: TextFormField(
                                controller: _userTextController,
                                decoration: InputDecoration(
                                  hintText: "Nazwa użytkownika",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: RaisedButton(
                                  onPressed: () {
                                    members.add(_userTextController.text);
                                    postMember(_userTextController.text,
                                        widget.table.id);
                                    Navigator.of(context).pop();
                                    _showUsersDialog();
                                  },
                                  child: Text("Dodaj")),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ))));
  }

  Widget _buildUserElement(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [
          Text(members[index]),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
            child: RaisedButton(
              onPressed: () {
                members.removeAt(index);
                Navigator.of(context).pop();
                _showUsersDialog();
              },
              child: Text("Usuń"),
            ),
          )
        ],
      ),
    );
  }

  _showArchivedCardsDialog() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 0),
                        color: Color.fromRGBO(127, 140, 141, 0.5),
                        spreadRadius: 2)
                  ],
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                width: 400,
                height: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(370, 5, 0, 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.clear,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(90, 0, 0, 0),
                      child: Text(
                        "Zarchiwizowane karty",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showArchivedListsDialog();
                        },
                        child: Text("Przełącz na listy"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      height: 440,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: archivedCards.length,
                          itemBuilder: (context, index) {
                            return _buildArchivedCard(archivedCards[index]);
                          }),
                    )
                  ],
                ),
              ),
            ));
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );
}
