import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../storage_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // State variables
  final _loginFormKey = GlobalKey<FormState>();
  String _errorMessage = "";
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
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
          child: Text("Register here", style: TextStyle(fontSize: 30.0)),
        ),
        if (_errorMessage.length > 0) Text(_errorMessage),
        Form(
          key: _loginFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_circle_outlined, size: 30.0),
                  labelText: 'First Name',
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
                controller: lastNameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_circle_outlined, size: 30.0),
                  labelText: 'Last Name',
                ),
                // initialValue: 'Username',r
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email_outlined, size: 30.0),
                  labelText: 'E-mail',
                ),
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
                  labelText: 'password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              Container(
                  padding: EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    child: Text('Register', style: TextStyle(fontSize: 20.0)),
                    onPressed: () async {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      http.Response? response;
                      if (_loginFormKey.currentState!.validate()) {
                        setState(() {
                          _errorMessage = "";
                        });
                        try {
                          response = await http.post(
                              Uri.parse(
                                  "http://192.168.11.7:3000/api/register"),
                              body: {
                                "first_name": firstNameController.text,
                                "last_name": lastNameController.text,
                                "email": emailController.text,
                                "password": passwordController.text
                              });
                        } catch (e) {
                          setState(() {
                            _errorMessage = "server error";
                          });
                        }

                        if (response?.statusCode == 200) {
                          var storeData =
                              jsonDecode(response?.body ?? "{}") as Map;
                          storeData["token"] =
                              response?.headers["auth-token"] ?? "";
                          var globalStorage = context.read<AppGlobalStorage>();
                          await globalStorage.setProperties(storeData);
                          Navigator.pushNamedAndRemoveUntil(context, '/home',
                              (Route<dynamic> route) => false);
                        } else {
                          setState(() {
                            _errorMessage = "bad login";
                          });
                        }
                      } // END IF
                    },
                  ))
            ],
          ),
        )
      ],
    ));
  }
}
