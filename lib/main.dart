import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:aplikasi_cuaca/api/weather_service.dart'; // Import package permission_handler

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Cuaca'),
      ),
      body: FutureBuilder(
        future: _getCurrentLocationWeather(), // Get current location weather data
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final weatherData = snapshot.data!;
              final cityName = weatherData['cityName'];
              final temperature = weatherData['temperature'];
              final weather = weatherData['weather'];
              IconData iconData;

              // Determine the weather icon based on weather condition
              switch (weather.toLowerCase()) {
                case 'clear':
                  iconData = Icons.wb_sunny;
                  break;
                case 'clouds':
                  iconData = Icons.cloud;
                  break;
                case 'rain':
                  iconData = Icons.beach_access;
                  break;
                case 'thunderstorm':
                  iconData = Icons.flash_on;
                  break;
                case 'drizzle':
                  iconData = Icons.grain;
                  break;
                case 'snow':
                  iconData = Icons.ac_unit;
                  break;
                case 'mist':
                  iconData = Icons.blur_on;
                  break;
                default:
                  iconData = Icons.error_outline;
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        cityName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Temperature: $temperature°C',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Weather: $weather',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        iconData,
                        size: 50,
                        color: Color.fromARGB(255, 46, 235, 8), // You can change the color as needed
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getCurrentLocationWeather() async {
    try {
      if (!(await Permission.location.status.isGranted)) {
        await Permission.location.request();
      }
      
      // Cek status izin lokasi
      if (await Permission.location.serviceStatus.isEnabled) {
        // Lakukan pengambilan lokasi jika izin sudah diberikan dan layanan lokasi diaktifkan
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high); // Get current position
        final weatherService = WeatherService();
        final weatherData = await weatherService.fetchWeatherDataByCoordinates(
            position.latitude, position.longitude); // Fetch weather data by coordinates
        return {'cityName': weatherData['name'], 'temperature': weatherData['main']['temp'], 'weather': weatherData['weather'][0]['main']};
      } else {
        throw Exception('Location service is disabled');
      }
    } catch (e) {
      print('Error getting location: $e');
      return {'cityName': 'Unknown', 'temperature': 'Unknown', 'weather': 'Unknown'};
    }
  }
}
