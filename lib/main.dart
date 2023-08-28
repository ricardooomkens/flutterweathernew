import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '4e09c58dd8b7f4d6b4e938c67cc73779'; // api key
  TextEditingController cityController = TextEditingController();
  String city = 'Spijkenisse'; // Default  on boot
  String temperature = '';
  String description = '';
  IconData weatherIcon = Icons.cloud; // Default icon

  Future<void> fetchWeatherData(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'].toString();
        description = data['weather'][0]['description'];
        // Map weather conditions to place icons
        weatherIcon = _getWeatherIcon(data['weather'][0]['id']);
      });
    }
  }

  IconData _getWeatherIcon(int condition) {
    if (condition < 300) {
      return Icons.flash_on; // Thunderstorm
    } else if (condition < 400) {
      return Icons.waves; // Drizzle
    } else if (condition < 600) {
      return Icons.cloud_queue; // Rain
    } else if (condition < 700) {
      return Icons.ac_unit; // Snow
    } else if (condition < 800) {
      return Icons.blur_on; // Atmosphere
    } else if (condition == 800) {
      return Icons.wb_sunny; // Clear
    } else {
      return Icons.cloud; // Clouds
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              weatherIcon,
              size: 64,
            ),
            Text(
              'Weather in $city',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Temperature: $temperature°C',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'Enter city name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  city = cityController.text;
                  fetchWeatherData(city);
                });
              },
              child: Text('Get Weather'),
            ),
          ],
        ),
      ),
    );
  }
}
