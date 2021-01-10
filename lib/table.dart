import 'package:trello_app/list.dart';

import 'card.dart';

class TrelloTable {
  String id;
  String name;
  String imageUrl;
  List<String> members = [];
  List<TrelloList> lists = [];
  List<TrelloCard> archivedCards = [];
  List<TrelloList> archivedLists = [];
  TrelloTable(String name, String id) {
    this.name = name;
    this.id = id;
  }
}
