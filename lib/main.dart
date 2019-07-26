import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eibar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      // home: TeacherSearchScreen(title: 'Find YOUR teacher!'),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<TeacherSearchScreen> {
  // State variables
  final _loginFormKey = GlobalKey<FormState>();

  // Other methods/functions

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Image.asset('/assets/img/eibar_icon.png'),
        Text("Please log in"),
        Form(
          key: _loginFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'e-mail address',
                  labelText: 'e-mail',
                ),
                autofocus: true,
                // initialValue: 'Username',
                style: TextStyle(fontSize: 20.0),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              RaisedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_loginFormKey.currentState.validate()) {
                    // Process data.
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class TeacherSearchScreen extends StatefulWidget {
  TeacherSearchScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TeacherSearchScreenState createState() => _TeacherSearchScreenState();
}

class _TeacherSearchScreenState extends State<TeacherSearchScreen> {
  List _availability = [];
  Set<Marker> _locations = Set();

  GoogleMapController mapController;
  final LatLng _center = const LatLng(35.657994, 139.727557);

  void _onMapCreated(GoogleMapController controller) async {
    // PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    // if (permission != PermissionStatus.granted) {
    //   Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.locationWhenInUse]);
    // }
    mapController = controller;
    await _updateAvailability();
    // Set<Marker> = {New Marker(LatLng())}
    // Set.of(New Marker(LatLng:))
    // debugPrint(jsonEncode(_availability));
  }

  Future<http.Response> fetchAvailability() async {
    return await http.get('https://eibar-stage.herokuapp.com/api/availability');
  }

  void _tapMarker(teacherId, teacherName) async {
    // var response = await http.get('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}');
    // var data = jsonEncode(response.body);
    // debugPrint(data);
    Route route = MaterialPageRoute(
        builder: (context) =>
            TeacherLessonPage(teacherId: teacherId, teacherName: teacherName));
    Navigator.push(context, route);
  }

  void _updateAvailability() async {
    var teacherResponse = await fetchAvailability();
    await setState(() {
      _availability = jsonDecode(teacherResponse.body);
    });
    _locations = Set();
    _availability.forEach((teacher) {
      // LatLng newLL = LatLng(teacher.lat, teacher.long);
      _locations.add(Marker(
        markerId: MarkerId(teacher['teacher_id']),
        position: LatLng(teacher['lat'], teacher['long']),
        consumeTapEvents: false,
        infoWindow: InfoWindow(
          title: teacher['name'],
          snippet: 'ID: ${teacher['teacher_id']}  Rating: ${teacher['rating']}',
          onTap: () {
            _tapMarker(teacher['teacher_id'], teacher['name']);
          },
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        // myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 16.0,
        ),
        markers: _locations,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateAvailability,
        tooltip: 'Get Teachers',
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class TeacherLessonPage extends StatefulWidget {
  TeacherLessonPage({Key key, this.teacherId, this.teacherName})
      : super(key: key);

  final String teacherId;
  final String teacherName;
  @override
  _TeacherLessonPageState createState() =>
      _TeacherLessonPageState(teacherId: teacherId, teacherName: teacherName);
}

class _TeacherLessonPageState extends State<TeacherLessonPage> {
  String teacherId;
  String teacherName;
  Map _teacher = {"name": "-", "specialty": "-"};
  List<Map<String, String>> _lessons = [
    {"startTime": "-", "cost": "-"}
  ];
  List<Widget> _stars = [
    Text(
      'Rating: ',
    )
  ];
  Uint8List _teacherPhoto;
  _TeacherLessonPageState({this.teacherId, this.teacherName});
  // Teacher _teacher = Teacher(name: "-", specialty: "-", rating: 0);
  // "0006": [
  //   {
  //     startTime: "16:00",
  //     cost: "3000 yen"
  //   },
  // ],

  List<Widget> ratingStars(int rating) {
    List<Widget> widgetList = <Widget>[]; //List();
    // widgetList.add(Text('Rating: ', ));
    int limit = rating;
    for (int i = 0; i < limit; i = i + 1) {
      widgetList.add(Icon(Icons.star, color: Colors.amber));
    }
    return widgetList;
  }

  List<Map<String, String>> processLessons(lessons) {
    List<Map<String, String>> lessonList = List();
    lessons.forEach((lesson) {
      lessonList
          .add({"startTime": lesson['startTime'], "cost": lesson['cost']});
    });
    return lessonList;
  }

  Future<List<dynamic>> fetchData(teacherId) {
    // [];
    // futureList.add(http.get('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}'));
    // futureList.add(http.get('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}/lessons'));
    debugPrint("getting data from API");
    return Future.wait([
      http.get('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}'),
      http.get(
          'https://eibar-stage.herokuapp.com/api/teachers/${teacherId}/lessons')
      // ,
      // http.readBytes('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}/photo')
    ]);
  }

  // Future<http.Response> fetchTeacherDetails(teacherId) {
  //   return http.get('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}');
  // }
  // Future<http.Response> fetchLessonDetails(teacherId) {
  //   return http.get('https://eibar-stage.herokuapp.com/api/teachers/${teacherId}/lessons');
  // }

  List<Widget> listLessons(List<Map> lessons) {
    List<Widget> widgetList = <Widget>[];
    lessons.forEach((lesson) {
      widgetList.add(Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Time: ${lesson["startTime"]}'),
                Text('Cost: ${lesson["cost"]}')
              ]),
        ),
      ));
    });
    return widgetList;
  }

  // void getTeacherLessons () async {
  // }

  @override
  initState() {
    // getTeacherLessons();
    // var detailsFuture = fetchTeacherDetails(teacherId);

    fetchData(teacherId).then((responses) {
      debugPrint("got stuff from API");
      setState(() {
        _teacher = jsonDecode(responses[0].body);
        _stars.addAll(ratingStars(jsonDecode(responses[0].body)["rating"]));
        _lessons = processLessons(jsonDecode(responses[1].body));
        // _teacherPhoto = responses[2].bodyBytes;
        // _teacherPhoto = responses[0].bodyBytes;
      });
    });
    // .catchError((e) {debugPrint(e.toString())});
    //debugPrint(_teacherPhoto.toString());
    // return fetchLessonDetails(teacherId);
    // .then((response) {
    //   setState(() {
    //     _lessons = processLessons(jsonDecode(response.body));
    //   });
    //   debugPrint(_teacher.toString());
    //   debugPrint(_lessons.toString());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(teacherName),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                  color: Colors.grey[200],
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 70,
                              width: 70,
                              color: Colors.amber[600],
                              child: Text('picture'),
                              // child: Image.memory(
                              //   bytes: _teacherPhoto
                              // )
                            ),
                            Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Specialty: ${_teacher['specialty']}',
                                      textAlign: TextAlign.left,
                                    ),
                                    Row(
                                      children:
                                          _stars, //ratingStars(_teacher['rating']),
                                    ),
                                  ],
                                )),
                          ]))),
              Expanded(
                  child: Container(
                      child: ListView(children: listLessons(_lessons))))
            ],
          ),
        ));
  }
}

// class Teacher {
//   String name;
//   String specialty;
//   int rating;
//   // Teacher(){
//   //   this.name = "-";
//   //   this.specialty = "-";
//   //   this.rating = 0;
//   // }   // Default constructor
//   Teacher({this.name, this.specialty, this.rating});
// }

// Column(
//   children: <Widget>[
//     Container(
//       height: 400.0,
//       child:
//     ListView (
//       children: <Widget>[
//         Container(
//           height: 50,
//           color: Colors.amber[600],
//           child: const Center(child: Text('Entry A')),
//         ),
//         Container(
//           height: 50,
//           color: Colors.amber[500],
//           child: const Center(child: Text('Entry B')),
//         ),
//         Container(
//           height: 50,
//           color: Colors.amber[100],
//           child: const Center(child: Text('Entry C')),
//         ),
//       ],
//     ),
//   ],
// ),
