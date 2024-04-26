import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:aplikasi_cuaca/pages/constants.dart';

class WeatherService {
  Future<Map<String, dynamic>> fetchWeatherDataByCoordinates(double latitude, double longitude) async {
    final url =
        '${Constants.openWeatherBaseURL}/weather?lat=$latitude&lon=$longitude&appid=${Constants.openWeatherApiKey}&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }
}
