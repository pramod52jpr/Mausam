import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class WeatherPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeatherPage();
}

class _WeatherPage extends State {
  bool contact = false;
  var city;
  var cityDetails;
  var weather;
  var weatherType = "";
  List fetchCountry = [];
  List<DropDownValueModel> dropdown = [];

  Future fetchLocation() async {
    http.Response response;
    response = await http.get(Uri.parse(
        "https://pkgstore.datahub.io/core/world-cities/world-cities_json/data/5b3dd46ad10990bca47b04b4739a02ba/world-cities_json.json"));
    fetchCountry = jsonDecode(response.body);
    dropdown = fetchCountry.map((e) {
      return DropDownValueModel(
        value: "${e['name']}",
        name: "${e['name']}, ${e['subcountry']}, ${e['country']}",
      );
    }).toList();
    setState(() {});
  }

  Future getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission askPermission = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      List place = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);
      city = place[0].locality;
      setState(() {});
    }
  }

  Future fetchCityDetails() async {
    http.Response response;
    response = await http.get(Uri.parse(
        "https://api.openweathermap.org/geo/1.0/direct?q=$city&appid=2b8eddd55cedb367a0c59f60a6dc059e"));
    cityDetails = jsonDecode(response.body);
    setState(() {});
  }

  Future fetchWeather() async {
    http.Response response;
    response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${cityDetails[0]['lat']}&lon=${cityDetails[0]['lon']}&appid=2b8eddd55cedb367a0c59f60a6dc059e"));
    weather = jsonDecode(response.body);
    setState(() {});
  }

  Future mausamchange() async {
    await fetchCityDetails()
        .then((cityValue) => fetchWeather().then((weatherValue) {
              switch (weather['weather'][0]['main']) {
                case "Thunderstorm":
                  weatherType = "assets/images/thunderstorm.jpg";
                  break;
                case "Rain":
                  weatherType = "assets/images/rain.jpg";
                  break;
                case "Drizzle":
                  weatherType = "assets/images/rain.jpg";
                  break;
                case "Snow":
                  weatherType = "assets/images/snow.jpg";
                  break;
                case "Clouds":
                  weatherType = "assets/images/clouds.jpg";
                  break;
                case "Clear":
                  weatherType = "assets/images/clear.jpg";
                  break;
                case "Mist":
                  weatherType = "assets/images/mist.jpg";
                  break;
                default:
                  weatherType = "assets/images/clear.jpg";
              }
              setState(() {});
            }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocation().then(
        (paramValue) => getLocation().then((locationValue) => mausamchange()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/icons/appIcon.png",
              scale: 10,
            ),
            SizedBox(width: 5),
            Text(
              "Mausam",
              style: TextStyle(
                color: Colors.white,
                fontSize: 45,
                fontFamily: "EBGaramontEb",
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.black,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      floatingActionButton: SizedBox.square(
        dimension: 80,
        child: FloatingActionButton(
          splashColor: Colors.blue,
          tooltip: contact ? "See Weather" : "About Owner",
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
          onPressed: () {
            contact = !contact;
            setState(() {});
          },
          child: contact
              ? FaIcon(
                  FontAwesomeIcons.cloudSunRain,
                  size: 40,
                )
              : FaIcon(
                  FontAwesomeIcons.user,
                  size: 40,
                ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          Future.delayed(
            Duration(seconds: 3),
            () {
              setState(() {});
            },
          );
        },
        child: SingleChildScrollView(
          child: Stack(
            children: [
              weatherType.isNotEmpty
                  ? Image.asset(
                      weatherType,
                      height: media.size.height * 0.883,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.3),
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(10),
                child: DropDownTextField(
                  clearOption: false,
                  textFieldDecoration: InputDecoration(
                    hintText: "Select Any City",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0, color: Colors.transparent)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0, color: Colors.transparent)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  searchDecoration: InputDecoration(hintText: "Search City"),
                  textStyle: TextStyle(fontSize: 20, color: Colors.white),
                  initialValue: city,
                  dropDownIconProperty:
                      IconProperty(color: Colors.white, size: 30),
                  enableSearch: true,
                  dropDownList: dropdown,
                  onChanged: (value) {
                    city = value.value;
                    setState(() {});
                    mausamchange();
                    contact = false;
                    setState(() {});
                  },
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 120),
                  height: 350,
                  width: 350,
                  child: Card(
                    shadowColor: Colors.blue,
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(200)),
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    child: contact
                        ? Column(
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Contact Us",
                                style: TextStyle(
                                    fontSize: 40,
                                    fontFamily: "EBGaramontRg",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                "Wanna Connect With Us?",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontFamily: "EBGaramontRg",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Pramod Pandit",
                                style: TextStyle(
                                    fontSize: 40,
                                    fontFamily: "EBGaramontEb",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "pramod52jpr@gmail.com",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: "EBGaramontRg",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "9991969489",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: "EBGaramontRg",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Thank You ...",
                                style: TextStyle(
                                    fontSize: 40,
                                    fontFamily: "EBGaramontRg",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )
                            ],
                          )
                        : Column(
                            children: weather == null
                                ? [shimmer()]
                                : [
                                    Text(
                                      "${(weather['main']['temp'] - 273.15).round()}°",
                                      style: TextStyle(
                                        fontSize: 90,
                                        color: Colors.white,
                                        fontFamily: "EBGaramontEb",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        "Min: ${(weather['main']['temp_min'] - 273.15).round()}° | Max:${(weather['main']['temp_max'] - 273.15).round()}°",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "EBGaramontRg",
                                        )),
                                    Text("${weather['weather'][0]['main']}",
                                        style: TextStyle(
                                            fontSize: 40,
                                            color: Colors.white,
                                            fontFamily: "EBGaramontRg",
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        "${DateFormat("EEEE, MMM d, hh:mm a").format(DateTime.now())}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontFamily: "EBGaramontRg",
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      verticalDirection: VerticalDirection.up,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "${weather['name']}, ${weather['sys']['country']}",
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontFamily: "EBGaramontRg",
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget shimmer() {
  return Shimmer(
    child: Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white),
          height: 100,
          width: 100,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Colors.white),
          height: 20,
          width: 150,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          height: 40,
          width: 100,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white),
          height: 30,
          width: 230,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          height: 50,
          width: 200,
        ),
      ],
    ),
    gradient: LinearGradient(colors: [
      Color.fromARGB(177, 228, 228, 228),
      Color.fromARGB(177, 199, 199, 199),
    ]),
  );
}
