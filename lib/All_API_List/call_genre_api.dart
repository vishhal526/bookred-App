import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookred/All_API_List/API_constants.dart';

class Genre_Call {

  Future<List<dynamic>> fetchBooksByGenre(dynamic id) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.genreUrl + "book/" + id));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load Books");
      }
    } catch (error) {
      print("Error Fetching Books by Genre :$error");
      return [];
    }
  }

  Future<List<dynamic>> fetchGenre() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.genreUrl+ "random"));
      print("Data = ${json.decode(response.body)}");
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load Books");
      }
    } catch (error) {
      print("Error Fetching Books by Genre :$error");
      return [];
    }
  }
}
