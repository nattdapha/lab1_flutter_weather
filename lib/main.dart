import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CityListScreen(),
    );
  }
}

class CityListScreen extends StatelessWidget {
  final List<String> cities = ['Bangkok', 'New York', 'London', 'Tokyo', 'Sydney'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather City'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListTile(
                leading: Icon(Icons.location_city, color: Colors.purpleAccent),
                title: Text(
                  cities[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.purpleAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetailScreen(city: cities[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class WeatherDetailScreen extends StatefulWidget {
  final String city;

  const WeatherDetailScreen({super.key, required this.city});

  @override
  _WeatherDetailScreenState createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late Future<WeatherResponse> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getData(widget.city);
  }

  Future<WeatherResponse> getData(String city) async {
    var client = http.Client();
    try {
      var response = await client.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=6378ac581297b40ccb71e6f85e65e17a'));
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception("Failed to load data");
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FutureBuilder<WeatherResponse>(
            future: weatherData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.redAccent),
                );
              } else if (snapshot.hasData) {
                var weather = snapshot.data!.weather[0];
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'City: ${snapshot.data!.name}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${snapshot.data!.main.temp}°C',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.network(
                            'https://openweathermap.org/img/w/${weather.icon}.png',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Min Temp: ${snapshot.data!.main.tempMin}°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        'Max Temp: ${snapshot.data!.main.tempMax}°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        'Pressure: ${snapshot.data!.main.pressure} hPa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        'Humidity: ${snapshot.data!.main.humidity}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        'Sea Level: ${snapshot.data!.main.seaLevel ?? "N/A"} m',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        'Cloudiness: ${snapshot.data!.clouds.all}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      Text(
                        'Rain (last hour): ${snapshot.data!.rain?.d1h ?? 0} mm',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sunset: ${DateTime.fromMillisecondsSinceEpoch(snapshot.data!.sys.sunset * 1000)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Weather: ${weather.description}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('No data');
              }
            },
          ),
        ),
      ),
    );
  }
}

class WeatherResponse {
  final Main main;
  final List<Weather> weather;
  final Clouds clouds;
  final Rain? rain;
  final Sys sys;
  final String name;

  WeatherResponse({
    required this.main,
    required this.weather,
    required this.clouds,
    required this.sys,
    required this.name,
    this.rain,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    var weatherList = json['weather'] as List;
    List<Weather> weather = weatherList.map((i) => Weather.fromJson(i)).toList();

    return WeatherResponse(
      main: Main.fromJson(json['main']),
      weather: weather,
      clouds: Clouds.fromJson(json['clouds']),
      sys: Sys.fromJson(json['sys']),
      name: json['name'],
      rain: json['rain'] != null ? Rain.fromJson(json['rain']) : null,
    );
  }
}

class Main {
  final double temp;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int? seaLevel;

  Main({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    this.seaLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp'].toDouble(),
      tempMin: json['temp_min'].toDouble(),
      tempMax: json['temp_max'].toDouble(),
      pressure: json['pressure'],
      humidity: json['humidity'],
      seaLevel: json['sea_level'],
    );
  }
}

class Weather {
  final String description;
  final String icon;

  Weather({required this.description, required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class Clouds {
  final int all;

  Clouds({required this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(
      all: json['all'],
    );
  }
}

class Rain {
  final double? d1h;

  Rain({this.d1h});

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(
      d1h: (json['1h'] as num?)?.toDouble(),
    );
  }
}

class Sys {
  final int sunset;

  Sys({required this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      sunset: json['sunset'],
    );
  }
}
