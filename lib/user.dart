class User {
  String token;
  List<String> teams = ["private"];
  List<List<String>> tables = [[]];
  List<List<String>> teamMembers = [[]];
  List<String> visibility = [];
  void clear() {
    token = "";
    teams = ["private"];
    tables = [[]];
    teamMembers = [[]];
  }
}
