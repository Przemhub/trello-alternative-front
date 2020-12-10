import 'dart:collection';

class User {
  String token;
  List<String> teams = ["private"];
  List<List<String>> tables = [[]];
  List<List<String>> teamMembers = [[]];
  List<String> visibility = [];
  Map<String, String> tableToID = {};
  void clear() {
    token = "";
    teams = ["private"];
    tables = [[]];
    teamMembers = [[]];
  }
}
