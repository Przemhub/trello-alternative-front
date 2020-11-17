class User {
  String email;
  String token;
  String password;
  List<String> teams = ["private"];
  List<List<String>> tables = [[]];
  List<List<String>> teamMembers = [[]];
  void clear() {
    email = "";
    token = "";
    password = "";
    teams = ["private"];
    tables = [[]];
    teamMembers = [[]];
  }
}
