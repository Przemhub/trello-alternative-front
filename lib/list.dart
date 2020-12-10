import 'package:trello_app/card.dart';

class TrelloList {
  String name;
  String id;
  List<TrelloCard> cards = [];
  TrelloList(String name) {
    this.name = name;
  }
}
