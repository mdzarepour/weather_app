import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/model/weather.dart';

class WeatherService {
  String apiKey = '7c75856312984912037d8c4ea863d7ef';
  String baseUrl = 'https://api.openweathermap.org/data';

  Future<String> getUserCity() async {
    //check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.error('we dont have permistoin to acces to location');
      }
    }
    //get user position
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 100);
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    //convert position
    double latitude = position.latitude;
    double longitude = position.longitude;
    List<Placemark> placemark =
        await placemarkFromCoordinates(latitude, longitude);
    String? city = placemark[0].locality;
    return city ?? 'unknown';
  }

  Future<Weather> getWeatherData(String city) async {
    late Weather weather;
    Response response = await Dio().get(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
    if (response.statusCode == 200) {
      weather = Weather.fromJson(response.data);
    }
    return weather;
  }
}
