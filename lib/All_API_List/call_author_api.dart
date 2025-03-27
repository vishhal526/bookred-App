import 'package:bookred/All_API_List/API_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthorService {
  ApiConstants api = ApiConstants();

  Future<List<dynamic>> getAllAuthor() async {
    var response = await http.get(Uri.parse(ApiConstants.authorUrl + "app"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load Author");
    }
  }

  Future<List<Map<String, dynamic>>> BookByAuthor(String authorId) async {
    try {
      final response = await http.get(
          Uri.parse("${ApiConstants.authorUrl}books/$authorId")
      );

      if (response.statusCode == 200) {
        print("\nGot books by authorID");
        print("Response body: ${response.body}");

        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print("Error: ${response.statusCode}");
        throw Exception("Error loading books: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception caught: $e");
      throw Exception("Something went wrong: $e");
    }
  }

  Future<List<Map<String, dynamic>>> RandomAuthor() async {
    try {
      final response = await http.get(
          Uri.parse("${ApiConstants.authorUrl}random/")
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print("Error: ${response.statusCode}");
        throw Exception("Error loading Authors: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception caught: $e");
      throw Exception("Something went wrong: $e");
    }
  }

  Future<dynamic> FollowAuthor(String authorID, bool isfollowed, int follower) async {
    String? userId = await api.getUserIdFromPrefs();

    Map<String, dynamic> requestBody = {
      "userId": userId,
      "follower": follower,
      "isfollowed": isfollowed
    };

    var response = await http.post(
        Uri.parse(ApiConstants.authorUrl + "follow/$authorID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));

    if (response.statusCode == 200) {
      print("Author followed succssfully");
      var data = jsonDecode(response.body);
      return data["followerCount"];
    } else {
      print("Failed to Follow Author with status code ${response.statusCode}");
    }
  }

  Future<dynamic> AuthorById(String authorId) async {
    try {
      String? userId = await api.getUserIdFromPrefs();

      final Map<String, dynamic> requestBody = {
        'userID': userId,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.authorUrl}app/$authorId"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print("✅ Book fetched successfully.");
        print(
            "\nData imported from the backend = ${jsonDecode(response.body)}");
        return json
            .decode(response.body); // Should include book info + user status
      } else {
        print("❌ Failed with status code: ${response.statusCode}");
        throw Exception('Failed to load book');
      }
    } catch (error) {
      print('🚫 Error fetching author: $error');
      return null;
    }
  }
}
