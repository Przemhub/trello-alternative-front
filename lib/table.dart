class TrelloTable {
  String name;
  String imageUrl;
  List<String> lists;
  List<List<String>> cards;
  TrelloTable(String name, String imgUrl) {
    this.name = name;
    this.imageUrl = imgUrl;
  }
}
