import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import './widgets/spinner.dart';
import 'package:provider/provider.dart';
import '../../storage_preferences.dart';

void navigateToCorrectStartScreen(BuildContext context) async {
  var globalStorage = context.read<AppGlobalStorage>();
  await globalStorage.setPropertiesFromStorage();
  if (globalStorage.values["_token"] == "") {
    Navigator.popAndPushNamed(context, "/login");
  } else {
    Navigator.popAndPushNamed(context, "/home");
  }
}

void logoutUser(context, appGlobalStorage) async {
  await appGlobalStorage.resetProperties();
  Navigator.pushNamedAndRemoveUntil(
      context, '/login', ModalRoute.withName('/login'));
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance
        ?.addPostFrameCallback((_) => navigateToCorrectStartScreen(context));

    return Scaffold(
        body: Center(
      child: ProgressSpinner(),
    ));
  }
}

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // State variables

  var _selectedIndex = 1;
  // Other methods/functions
  // final Future<String> _getUserData () {
  //
  // }
  // build
  @override
  Widget build(BuildContext context) {
    var appGlobalStorage = context.read<AppGlobalStorage>();
    String firstName = appGlobalStorage.values["firstName"] ?? "";
    String lastName = appGlobalStorage.values["lastName"] ?? "";
    String email = appGlobalStorage.values["email"] ?? "";

    List<Widget> pages = [
      Center(child: Text("Hello")),
      ListView(children: [
        Container(
          margin: EdgeInsets.all(20.0),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text("User Profile", style: TextStyle(fontSize: 30.0)),
              Container(width: 10.0),
              IconButton(
                  icon: Icon(Icons.edit, size: 30.0, color: Colors.indigo),
                  onPressed: () => {debugPrint("hi")})
            ]),
          ),
        ),
        Divider(color: Color(0x88000000)),
        ListTile(
          leading: Text("First", style: TextStyle(fontSize: 20.0)),
          title: Text(firstName, style: TextStyle(fontSize: 20.0)),
          minLeadingWidth: 60.0,
        ),
        Divider(color: Color(0x88000000)),
        ListTile(
            minLeadingWidth: 60.0,
            leading: Text("Last", style: TextStyle(fontSize: 20.0)),
            title: Text(lastName, style: TextStyle(fontSize: 20.0)),
            trailing: IconButton(
                icon: Icon(Icons.edit, size: 30.0, color: Colors.indigo),
                onPressed: () => {
                      // showDialog(child: new Dialog(
                      // child: new Column(
                      // children: <Widget>[
                      // new TextField(
                      // decoration: new InputDecoration(hintText: "Update Info"),
                      // controller: _c,
                      //
                      // ),
                      // new FlatButton(
                      // child: new Text("Save"),
                      // onPressed: (){
                      // setState((){
                      // this._text = _c.text;
                      // });
                      // Navigator.pop(context);
                      // },
                      // )
                      // ],
                      // ),
                      //
                      // ), context: context);
                    })),
        Divider(color: Color(0x88000000)),
        ListTile(
          leading: Text("Email", style: TextStyle(fontSize: 20.0)),
          title: Text(email, style: TextStyle(fontSize: 20.0)),
          minLeadingWidth: 60.0,
        ),
      ]),
      Center(child: ProgressSpinner()),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Eibar Home"),
        elevation: 5.0,
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // SafeArea(child: Container(height: MediaQuery.of(context).padding.top, color: Colors.red)),
          Container(
            height: 90.0,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Eibar Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.logout_outlined, size: 30.0),
            title: Text("Logout",
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400)),
            onTap: () => logoutUser(context, appGlobalStorage),
          )
        ],
      )),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Teach',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Learn',
          ),
        ],
        currentIndex: _selectedIndex,
        iconSize: 40.0,
        selectedFontSize: 20.0,
        unselectedFontSize: 15.0,
        onTap: _onItemTapped,
      ),
    );
  }
}
