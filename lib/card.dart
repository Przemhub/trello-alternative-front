class TrelloCard {
  String name;
  String id;
  String description = "";
  String deadline = "brak";
  String parentName;
  List<String> activities = [];
  TrelloCard(String name) {
    this.name = name;
  }
}
