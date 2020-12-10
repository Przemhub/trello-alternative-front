import 'package:trello_app/list.dart';

class TrelloTable {
  String id;
  String name;
  String imageUrl;
  List<TrelloList> lists = [];
  TrelloTable(String name, String id) {
    this.name = name;
    this.id = id;
  }
}
