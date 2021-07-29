import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_monitoring/widgets/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:weather_monitoring/services/meteorology.dart';
import 'package:weather_monitoring/widgets/loading.dart';
import 'package:weather_monitoring/widgets/my_flutter_app_icons.dart';

class Home extends StatefulWidget {
  Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String key = "villes";
  List<String> cities = [];
  String choiceCity = "Ma ville actuelle";
  geocoding.Location? coordsChoiceCity;

  Location location = new Location();
  LocationData? locationData;
  Stream<LocationData>? stream;

  Meteorology? meteorology;
  AssetImage night = AssetImage("assets/n.jpg");
  AssetImage sun = AssetImage("assets/d1.jpg");
  AssetImage rain = AssetImage("assets/d2.jpg");

  @override
  void initState() {
    super.initState();
    getShared();
    listenToStream();
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
                                  elevation: MaterialStateProperty.all<double>(
                                      8.0),
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.white),
                                ),
                                child: new CustomText(
                                  "Ajouter une ville",
                                  color: Colors.blue,
                                )
                            )
                          ],
                        ));
                  } else if (i == 1) {
                    return new ListTile(
                      title: new CustomText(choiceCity),
                      onTap: () {
                        setState(() {
                          choiceCity = "Ma ville actuelle";
                          apiWeather();
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
                          coordsChoiceCity = null;
                          coordinatesFromCity();
                          Navigator.pop(context);
                        });
                      },
                    );
                  }
                }),
            color: Colors.blue,
          ),
        ),
        body: (meteorology == null) ?
        Center(
            child: new Loading()
          // child: new Text(
          //   choiceCity
          // )
        ) :
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: getBackground(),
                  fit: BoxFit.cover
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new CustomText(
                choiceCity,
                fontSize: 40.0,
                fontStyle: FontStyle.italic,
              ),
              new CustomText(
                meteorology!.description,
                fontSize: 30.0,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new Image(
                      image: getIcon()
                  ),
                  new CustomText(
                    "${meteorology!.temp.toInt()} °C",
                    fontSize: 75.0,
                  )
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  extra(
                      "${meteorology!.min.toInt()} °C",
                      MyFlutterApp.up
                  ),
                  extra(
                      "${meteorology!.min.toInt()} °C",
                      MyFlutterApp.down
                  ),
                  extra(
                      "${meteorology!.pressure.toInt()}",
                      MyFlutterApp.temperatire
                  ),
                  extra(
                      "${meteorology!.humidity.toInt()} %",
                      MyFlutterApp.drizzle
                  )
                ],
              )
            ],
          ),
        )
    );
  }

  Column extra(String data, IconData iconData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Icon(
          iconData,
          color: Colors.white,
          size: 32.0,
        ),
        new CustomText(
            data
        )
      ],
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
    List<String>? list = sharedPreferences.getStringList(key);
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

  AssetImage getIcon() {
    String icon = meteorology!.icon.replaceAll('d', '').replaceAll('n', '');
    return AssetImage("assets/$icon.png");
  }

  AssetImage getBackground() {
    if (meteorology!.icon.contains("n")) {
      return night;
    } else {
      if (meteorology!.icon.contains("01") || meteorology!.icon.contains("03") || meteorology!.icon.contains("03")) {
        return sun;
      } else {
        return rain;
      }
    }
  }

  // Once
  getFirstLocation() async {
    try {
      locationData = await location.getLocation();
      print("Nouvelle position: ${locationData!.latitude} / ${locationData!.longitude}");
      locationToString(locationData);
    } catch (error) {
      print("Nous avons une erreur : $error");
    }
  }

  // Each Change
  listenToStream() {
    stream = location.onLocationChanged;
    stream!.listen((newPosition) {
      // print("New => ${newPosition.latitude} ------ ${newPosition.longitude}");
      if ((locationData == null) || (newPosition.longitude != locationData!.longitude) && (newPosition.latitude != locationData!.latitude)) {
        setState(() {
          locationData = newPosition;
          locationToString(locationData);
        });
      }
    });
  }

  // Geocoding
  locationToString(LocationData? locationData) async {
    if (locationData != null) {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(locationData.latitude!, locationData.longitude!);
      setState(() {
        choiceCity = placemarks.first.locality!;
        apiWeather();
      });
    }
  }

  coordinatesFromCity() async {
    if (choiceCity != "Ma ville actuelle") {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(choiceCity);
      if (locations.length > 0) {
        geocoding.Location coordinates = locations.first;
        setState(() {
          coordsChoiceCity = coordinates;
          apiWeather();
        });
      }
    }
  }

  apiWeather() async {
    double? lat;
    double? lon;
    if (coordsChoiceCity != null) {
      lat = coordsChoiceCity!.latitude;
      lon = coordsChoiceCity!.longitude;
    } else if (locationData != null) {
      lat = locationData!.latitude!;
      lon = locationData!.longitude!;
    }
    if (lat != null && lon != null) {
        final key = "&APPID=" + dotenv.env['API_KEY']!;
        String lang = "&lang=${Localizations.localeOf(context).languageCode}";
        String baseAPI = "http://api.openweathermap.org/data/2.5/weather?";
        String coordsString = "lat=$lat&lon=$lon";
        String units = "&units=metric";
        String totalAPICall = baseAPI + coordsString + units + lang + key;

        final response = await http.get(Uri.parse(totalAPICall));
        if (response.statusCode == 200) {
          Map map = json.decode(response.body);
          setState(() {
            meteorology = Meteorology(map);
          });
        }
    }
  }

}