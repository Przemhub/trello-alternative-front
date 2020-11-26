import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trello_app/register_page.dart';
import 'package:trello_app/tables_page.dart';
import 'package:trello_app/user.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignInForm(),
          ),
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

User user = new User();

class _SignInFormState extends State<SignInForm> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  double _formProgress = 0;

  static const SERVER_IP = 'https://trello-alternative.herokuapp.com';

  void _updateFormProgress() {
    var progress = 0.0;
    var controllers = [_passwordTextController, _emailTextController];

    for (var controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }

  signIn() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var userEmail = _emailTextController.text;
    var password = _passwordTextController.text;
    var token = await attemptLogIn(userEmail, password);
    print("User logged in succesfully");
    if (token != null) {
      print("user token: $token");
      user.token = token;
      int response = await getTablesByUser(token);
      if (response == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Tables(
                      user: user,
                    )));
      }
    } else {
      displayDialog(context, "An Error Occurred",
          "No account was found matching that Email and password");
    }
  }

  Future<int> getTablesByUser(String userId) async {
    var res = await http.get("$SERVER_IP/boards/",
        headers: {HttpHeaders.authorizationHeader: "Bearer " + userId});

    if (res.statusCode != 200) {
      displayDialog(context, "An Error Occurred",
          "No account was found matching that Email");
    } else {
      var jsonResponse = json.decode(res.body);
      print(jsonResponse);
      for (var table in jsonResponse["boards"]) {
        //table["team"] == null means table is private
        if (table["team"] != null) {
          int index = user.teams.indexOf(table["team"]);
          //if team exists, insert table to a specific nested list, else add new team
          if (index != -1) {
            user.tables[index].add(table["name"]);
          } else {
            user.teams.add(table["team"]);
            user.tables.add([table["name"]]);
          }
        } else {
          user.tables[0].add(table["name"]);
        }
      }
    }
    return res.statusCode;
  }

  Future<String> attemptLogIn(String email, String password) async {
    print('serverip:$SERVER_IP');
    print('password:$password');
    print('email:$email');

    var res = await http.post("$SERVER_IP/api/user/login",
        body:
            jsonEncode(<String, String>{"email": email, "password": password}),
        headers: <String, String>{"Content-Type": "application/json"});
    if (res.statusCode == 200) return res.body;
    return null;
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedProgressIndicator(value: _formProgress),
          Text('Sign in', style: Theme.of(context).textTheme.headline4),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _emailTextController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _passwordTextController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(150.0, 0.0, 0.0, 0.0),
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.white;
                    }),
                    backgroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.blue;
                    }),
                  ),
                  onPressed: () {
                    signIn();
                  },
                  child: Text('Sign in'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(70.0, 0.0, 0.0, 0.0),
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.blue;
                    }),
                    backgroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) {
                      return states.contains(MaterialState.disabled)
                          ? null
                          : Colors.white;
                    }),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen()));
                  },
                  child: Text('Go to Sign up'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double value;

  AnimatedProgressIndicator({
    @required this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnimatedProgressIndicatorState();
  }
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _colorAnimation;
  Animation<double> _curveAnimation;

  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1200), vsync: this);

    var colorTween = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.red, end: Colors.orange),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.orange, end: Colors.yellow),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.yellow, end: Colors.green),
        weight: 1,
      ),
    ]);

    _colorAnimation = _controller.drive(colorTween);
    _curveAnimation = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.animateTo(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => LinearProgressIndicator(
        value: _curveAnimation.value,
        valueColor: _colorAnimation,
        backgroundColor: _colorAnimation.value.withOpacity(0.4),
      ),
    );
  }
}
