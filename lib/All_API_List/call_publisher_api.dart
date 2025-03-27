import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookred/All_API_List/API_constants.dart';

class PublisherService {

  Future<List<dynamic>> getAllPublisher() async {
    var response = await http.get(Uri.parse(ApiConstants.publisherUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else{
      throw Exception("Failed to Load Publisher");
    }
  }

  Future<dynamic> PublisherById(String publisherID) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.publisherUrl}$publisherID"),
      );

      if (response.statusCode == 200) {
        print("✅ Publisher fetched successfully.");
        print(
            "\nData imported from the backend = ${jsonDecode(response.body)}");
        return json
            .decode(response.body); // Should include book info + user status
      } else {
        print("❌ Failed with status code: ${response.statusCode}");
        throw Exception('Failed to load Publisher');
      }
    } catch (error) {
      print('🚫 Error fetching Publisher: $error');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> BookByPublisher(String publisherId) async {
    try {
      final response = await http.get(
          Uri.parse("${ApiConstants.publisherUrl}book/$publisherId")
      );

      if (response.statusCode == 200) {
        print("\nGot books by publisherId");
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
}
