import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../storage_preferences.dart';
import '../../localize/eibar_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State variables
  final _loginFormKey = GlobalKey<FormState>();
  String _ErrorMessage = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // Other methods/functions

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(30.0, 70.0, 60.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 100.0,
            child:
                Image.asset('assets/img/eibar_icon.png', fit: BoxFit.fitHeight),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20.0),
            child: Text(EibarLocalizations.of(context)!.promptLogin,
                style: TextStyle(fontSize: 20.0)),
          ),
          if (_ErrorMessage.length > 0) Text(_ErrorMessage),
          Form(
            key: _loginFormKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email_outlined, size: 30.0),
                    hintText: 'e-mail',
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock_open, size: 30.0),
                    hintText: 'password',
                  ),
                  // initialValue: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    child: Text(EibarLocalizations.of(context)!.buttonLogin,
                        style: TextStyle(fontSize: 20.0)),
                    onPressed: () async {
                      http.Response? response;

                      if (_loginFormKey.currentState!.validate()) {
                        setState(() {
                          _ErrorMessage = "";
                        });
                        try {
                          response = await http.post(
                              Uri.parse("http://192.168.11.7:3000/api/login"),
                              body: {
                                "email": nameController.text,
                                "password": passwordController.text
                              });
                        } catch (e) {
                          setState(() {
                            _ErrorMessage = "server error";
                          });
                        }

                        if (response?.statusCode == 200) {
                          var storeData =
                              jsonDecode(response?.body ?? "{}") as Map;
                          storeData["token"] =
                              response?.headers["auth-token"] ?? "";
                          var globalStorage = context.read<AppGlobalStorage>();
                          await globalStorage.setProperties(storeData);
                          Navigator.popAndPushNamed(context, "/loading");
                        } else {
                          setState(() {
                            _ErrorMessage = "bad login";
                          });
                        }
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
