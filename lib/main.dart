import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_monitoring/widgets/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Weather Monitoring'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String key = "villes";
  List<String> cities = [];
  String? choiceCity;

  Location location = new Location();
  LocationData? locationData;
  Stream<LocationData>? stream;

  @override
  void initState() {
    super.initState();
    getShared();
    // location = new Location();
    // getFirstLocation();
    listenToStream();
  }

  // Once
  getFirstLocation() async {
    try {
      locationData = await location.getLocation();
      print(
          "Nouvelle position: ${locationData!.latitude} / ${locationData!.longitude}");
    } catch (error) {
      print("Nous avons une erreur : $error");
    }
  }

  // Each Change
  listenToStream() {
    stream = location.onLocationChanged;
    stream!.listen((newPosition) {
      print("New => ${newPosition.latitude} ------ ${newPosition.longitude}");

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: new Container(
          child: new ListView.builder(
              itemCount: cities.length + 2,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return DrawerHeader(
                      child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      new CustomText(
                        "Mes Villes",
                        fontSize: 22.0,
                      ),
                      new ElevatedButton(
                          onPressed: () {
                            addCity();
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(8.0),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: new CustomText(
                            "Ajouter une ville",
                            color: Colors.blue,
                          ))
                    ],
                  ));
                } else if (i == 1) {
                  return new ListTile(
                    title: new CustomText("Ma ville actuelle"),
                    onTap: () {
                      setState(() {
                        choiceCity = null;
                        Navigator.pop(context);
                      });
                    },
                  );
                } else {
                  String city = cities[i - 2];
                  return new ListTile(
                    title: new CustomText(city),
                    trailing: new IconButton(
                        onPressed: (() => delete(city)),
                        icon: new Icon(
                            Icons.delete,
                            color: Colors.white
                        )
                    ),
                    onTap: () {
                      setState(() {
                        choiceCity = city;
                        Navigator.pop(context);
                      });
                    },
                  );
                }
              }),
          color: Colors.blue,
        ),
      ),
      body: Center(
          child: new Text(
        (choiceCity == null ? "Ville actuelle" : choiceCity!),
      )),
    );
  }

  Future<Null> addCity() async {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext buildContext) {
        return new SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: CustomText(
            "Ajouter une ville",
            fontSize: 22.0,
            color: Colors.blue,
          ),
          children: [
            new TextField(
              decoration: new InputDecoration(labelText: "Ville : "),
              onSubmitted: (String str) {
                add(str);
                Navigator.pop(buildContext);
              },
            )
          ],
        );
      },
    );
  }

  void getShared() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? list = await sharedPreferences.getStringList(key);
    if (list != null) {
      setState(() {
        cities = list;
      });
    }
  }

  void add(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.add(str);
    await sharedPreferences.setStringList(key, cities);
    getShared();
  }

  void delete(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.remove(str);
    await sharedPreferences.setStringList(key, cities);
    getShared();
  }
}
