import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:bookred/All_API_List/API_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User_Service {
  ApiConstants api = ApiConstants();

  Future<dynamic> AddToLikeList(String bookId, bool isliked) async {
    try {
      String? userId = await api.getUserIdFromPrefs();

      if (userId == null) {
        print("⚠️ User ID not found in SharedPreferences.");
        return null; // Return null for clarity instead of an empty list
      }

      final Map<String, dynamic> requestBody = {
        'bookID': bookId,
        'userID': userId,
      };

      final response = await http.post(
          Uri.parse(ApiConstants.userUrl + "toggleLike"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[isliked ? 'islike' : "isunlike"];
      } else {
        throw Exception("Failed to like/unlike Books");
      }
    } catch (error) {
      print("Error liking/unliking book :$error");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> GetLikedBooks(String UserID) async {
    try {
      final response = await http
          .get(Uri.parse("${ApiConstants.userUrl}likedbooks/$UserID"));

      if (response.statusCode == 200) {
        print("\nGot Liked books");
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

  Future<List<Map<String, dynamic>>> GetBookmarkedBooks(String UserID) async {
    try {
      final response =
          await http.get(Uri.parse("${ApiConstants.userUrl}bookmark/$UserID"));

      if (response.statusCode == 200) {
        print("\nGot Bookmarked books");
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

  Future<Map<String,dynamic>> GetCurrentlyReadingBook() async {
    String? UserID = await api.getUserIdFromPrefs();

    var response = await http
        .get(Uri.parse(ApiConstants.userUrl + "currentlyReading/$UserID"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Data from the Backend for Currently Reading book = ${data}");
      return data;
    } else {
      throw Exception("Error Occured while Getting Currently Reading book");
    }
  }

  Future<List<Map<String, dynamic>>> GetReadBooks(String UserID) async {
    try {
      final response =
          await http.get(Uri.parse("${ApiConstants.userUrl}readbook/$UserID"));

      if (response.statusCode == 200) {
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

  Future<dynamic> AddToDislikeList(String bookId, bool isliked) async {
    try {
      String? userId = await api.getUserIdFromPrefs();

      if (userId == null) {
        print("⚠️ User ID not found in SharedPreferences.");
        return null; // Return null for clarity instead of an empty list
      }

      final Map<String, dynamic> requestBody = {
        'bookID': bookId,
        'userID': userId,
      };

      final response = await http.post(
          Uri.parse(ApiConstants.userUrl + "toggleDislike"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[isliked ? 'islike' : "isunlike"];
      } else {
        throw Exception("Failed to like/unlike Books");
      }
    } catch (error) {
      print("Error liking/unliking book :$error");
      return [];
    }
  }

  Future<List<dynamic>> GetFollowedAuthor() async {
    String? userId = await api.getUserIdFromPrefs();

    var response = await http
        .get(Uri.parse(ApiConstants.userUrl + "followedAuthor/$userId"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      return data;
    } else {
      throw Exception(
          "Error getting Followed Authors with status code ${response.statusCode}");
    }
  }

  Future<bool> deleteProfilePicture() async {
    String? userID = await api.getUserIdFromPrefs();

    var response = await http
        .delete(Uri.parse(ApiConstants.userUrl + "removePFP/$userID"));

    if (response.statusCode == 200) {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("pfp", "");
      print("Profile picture deleted");
      return true;
    } else {
      print("Error deleting image, statusCode: ${response.statusCode}");
      return false;
    }
  }

  Future<String> UploadProfilePicture(File profilepic) async {
    String? userID = await api.getUserIdFromPrefs();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.userUrl + "upload/$userID"),
    )..files
        .add(await http.MultipartFile.fromPath("profile_pic", profilepic.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      String profilePicture = data['updatedUser']['profilePicture'];

      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("pfp", profilePicture);

      print("Profile picture updated and saved in SharedPreferences");

      return "Success";
    } else {
      print(
          "\nError Occurred in uploading image ... with statusCode = ${response.statusCode}");
      return "Error Occurred";
    }
  }
}
