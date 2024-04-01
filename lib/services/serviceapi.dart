import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceAPI {
  final String BASE_URL = "https://api-donaciones.onrender.com/";
  // final String BASE_URL = "http://localhost:8282/";

  Future<List<Map<String, dynamic>>> get(String endpoint) async {
    final response = await http.get(Uri.parse(BASE_URL + endpoint));

    print(response
        .body);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      List<dynamic> exportList = responseData['msg'];

      List<Map<String, dynamic>> donaciones =
          exportList.map((json) => json).toList().cast<Map<String, dynamic>>();

      return donaciones;
    } else {
      throw Exception('Donation upload failed.');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse(BASE_URL + endpoint),
        headers: {"Content-Type": "application/json"}, body: json.encode(data));

    try {
      if (response.statusCode == 200) {
        print("Post request successful");
      } else {
        throw Exception('Failed to post');
      }
    } catch (e) {
      print(e);
    }

    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse(BASE_URL + endpoint),
        headers: {"Content-Type": "application/json"}, body: json.encode(data));

    try {
      if (response.statusCode == 200) {
        print("Put request successful");
      } else {
        print(response.body);
        throw Exception('Failed to put');
      }
    } catch (e) {
      print(e);
    }

    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final response = await http.delete(Uri.parse(BASE_URL + endpoint));

    try {
      if (response.statusCode == 200) {
        print(response.body);
        print("Delete request successful");
      } else {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      print(e);
    }

    return response;
  }
}