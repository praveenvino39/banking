import 'dart:convert';

import 'package:http/http.dart';

class HttpService {
  static Future<String?> getPublicIp() async {
    try {
      Response response =
          await get(Uri.parse("https://api.ipify.org/?format=json"));
      final data = jsonDecode(response.body);
      return data["ip"];
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCityByLatLong(double latitude, double longitude) async {
    try {
      Response response = await get(Uri.parse(
          "https://us1.locationiq.com/v1/reverse?key=pk.06f498d2d15fca6c86d671658c117c38&lat=$latitude&lon=$longitude&format=json"));
      final data = jsonDecode(response.body);
      return data["address"]["city"];
    } catch (e) {
      return null;
    }
  }
}
