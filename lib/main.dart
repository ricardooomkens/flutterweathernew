import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';
import 'settings_page.dart';

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
  final String apiKey = '4e09c58dd8b7f4d6b4e938c67cc73779'; // Your provided API key
  String city = '';
  String temperature = '';
  String description = '';
  IconData weatherIcon = Icons.cloud;
  late SharedPreferences prefs;
  List<ForecastItem> forecastItems = [];

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  void _initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    final storedCity = prefs.getString('defaultCity') ?? 'London';
    setState(() {
      city = storedCity;
    });
    await fetchWeatherAndForecastData(city); // Fetch data on app launch
  }

  Future<void> fetchWeatherAndForecastData(String cityName) async {
    await fetchWeatherData(cityName);
    await fetchForecastData(cityName);
  }

  Future<void> fetchWeatherData(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'].toString();
        description = data['weather'][0]['description'];
        weatherIcon = _getWeatherIcon(data['weather'][0]['id']);
      });
    }
  }

  Future<void> fetchForecastData(String cityName) async {
    final forecastResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric'));

    if (forecastResponse.statusCode == 200) {
      final forecastData = json.decode(forecastResponse.body);

      setState(() {
        forecastItems = [];

        final List<dynamic> forecasts = forecastData['list'];

        // Limit the loop to the number of available forecasts or 2, whichever is smaller.
        final numberOfForecasts = forecasts.length < 2 ? forecasts.length : 2;

        for (var i = 0; i < numberOfForecasts; i++) {
          final forecast = forecasts[i];
          final dateTime = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
          final temperature = forecast['main']['temp'].toDouble();
          final description = forecast['weather'][0]['description'];
          final weatherIcon = _getWeatherIcon(forecast['weather'][0]['id']);

          forecastItems.add(ForecastItem(
            dateTime: dateTime,
            temperature: temperature,
            description: description,
            weatherIcon: weatherIcon,
          ));
        }
      });
    }
  }

  IconData _getWeatherIcon(int condition) {
    if (condition >= 200 && condition < 300) {
      return WeatherIcons.thunderstorm; // Thunderstorm
    } else if (condition >= 300 && condition < 600) {
      return WeatherIcons.rain; // Drizzle/Rain
    } else if (condition >= 600 && condition < 700) {
      return WeatherIcons.snow; // Snow
    } else if (condition >= 700 && condition < 800) {
      return WeatherIcons.fog; // Atmosphere (Fog/Mist)
    } else if (condition == 800) {
      return WeatherIcons.day_sunny; // Clear Sky
    } else if (condition >= 801 && condition <= 804) {
      return WeatherIcons.cloudy; // Cloudy
    } else {
      return WeatherIcons.alien; // Default icon for unrecognized conditions
    }
  }

  void _navigateToSettings() async {
    final newDefaultCity = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage(defaultCity: city)),
    );

    if (newDefaultCity != null) {
      _updateDefaultCity(newDefaultCity);
    }
  }

  void _updateDefaultCity(String newDefaultCity) {
    prefs.setString('defaultCity', newDefaultCity);
    setState(() {
      city = newDefaultCity;
      fetchWeatherAndForecastData(city);
    });
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
      Padding(
      padding: const EdgeInsets.only(bottom: 30.0), // Adjust the padding as needed
        child: Icon(
          weatherIcon,
          size: 64,
        ),
      )


    ,
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
    Text(
    'Upcoming 4 Hours Forecast',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 10),
    Expanded(
    child: ListView.builder(
      itemCount: forecastItems.length,
      itemBuilder: (context, index) {
        final forecastItem = forecastItems[index];
        return ListTile(
          title: Row( // Wrap in a Row
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0), // Adjust the padding as needed
                child: Icon(forecastItem.weatherIcon),
              ),
              Text(
                '${forecastItem.dateTime.hour}:00 - ${forecastItem.temperature.toStringAsFixed(1)}°C',
              ),
            ],
          ),
          subtitle: Text(forecastItem.description),
        );
      },
    ),


    ),
      ],
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _navigateToSettings();
          }
        },
      ),
    );
  }
}

class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final IconData weatherIcon;

  ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.weatherIcon,
  });
}

