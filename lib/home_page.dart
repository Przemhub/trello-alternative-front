import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trello_app/table.dart';
import 'package:trello_app/user.dart';

class HomePage extends StatefulWidget {
  TrelloTable table;
  @override
  _HomePageState createState() => _HomePageState();
  // HomePage({Key key, @required this.table}) : super(key: key);
}

class _HomePageState extends State<HomePage> {
  List<String> listNames = ["ToDo", "Completed"];
  List<List<String>> cardNames = [
    ["ToDo 1", "ToDo 2"],
    ["Done 1", "Done 2"],
  ];
  void getData() async {
    // Response response = await get('endpoint adress');
    // Map data = jsonDecode(response.body);
  }
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trello Cards"),
      ),
      body: _buildBody(),
    );
  }

  TextEditingController _cardTextController = TextEditingController();
  TextEditingController _taskTextController = TextEditingController();
  TextEditingController _editListTextController = TextEditingController();
  _editList(int listIndex, String listName) {
    listNames[listIndex] = listName;
    setState(() {});
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
    listNames.add(text);
    cardNames.add([]);
    _cardTextController.text = "";
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
                    child: Text("Add Task"),
                  ),
                )
              ],
            ),
          );
        });
  }

  _addCard(int index, String text) {
    cardNames[index].add(text);
    _taskTextController.text = "";
    setState(() {});
  }

  _handleReOrder(int oldIndex, int newIndex, int index) {
    var oldValue = cardNames[index][oldIndex];
    cardNames[index][oldIndex] = cardNames[index][newIndex];
    cardNames[index][newIndex] = oldValue;
    setState(() {});
  }

  _buildBody() {
    return Stack(
      children: [
        ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listNames.length + 1,
          itemBuilder: (context, index) {
            if (index == listNames.length)
              return _buildAddListWidget(context);
            else
              return LongPressDraggable<dynamic>(
                data: {
                  "from": index,
                  "string": listNames[index],
                  "child": cardNames[index]
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
                        listNames[index],
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
                        itemCount: cardNames[index].length + 1,
                        itemBuilder: (context, index2) {
                          if (index2 == cardNames[index].length)
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
                  cardNames[data['from2']].remove(data['string2']);
                  cardNames[index].add(data['string2']);
                } else if (data['from'] == index) {
                  return;
                } else {
                  print("else");

                  listNames.remove(data['string']);
                  cardNames.removeAt(data['from']);
                  if (index < listNames.length) {
                    listNames.insert(index, data['string']);
                    cardNames.insert(index, data['child']);
                  } else {
                    listNames.add(data['string']);
                    cardNames.add(data['child']);
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
                    listNames[index],
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
                        itemCount: cardNames[index].length,
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
            child: Text(cardNames[index][innerIndex]),
          ),
        ),
        childWhenDragging: Container(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.greenAccent,
          child: Text(cardNames[index][innerIndex]),
        ),
        data: {"from2": index, "string2": cardNames[index][innerIndex]},
      ),
    );
  }
}

class _editListTextController {}
