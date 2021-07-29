class Meteorology {
  late String main;
  late String description;
  late String icon;
  var temp;
  var pressure;
  var humidity;
  var min;
  var max;

  Meteorology(Map map) {
    List weather = map["weather"];
    Map weatherMap = weather.first;
    this.main = weatherMap["main"];
    this.description = weatherMap["description"];
    this.icon = weatherMap["icon"];

    Map mainMap = map["main"];
    this.temp = mainMap["temp"];
    this.pressure = mainMap["pressure"];
    this.humidity = mainMap["humidity"];
    this.min = mainMap["temp_min"];
    this.max = mainMap["temp_max"];
  }
}