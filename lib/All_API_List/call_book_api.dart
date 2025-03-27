// lib/book_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookred/All_API_List/API_constants.dart';

class BookService {
  ApiConstants api = ApiConstants();

  Future<List<dynamic>> fetchallBooks() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.bookUrl + "app/"));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load Books");
      }
    } catch (error) {
      print("Error Fetching recommanded Books :$error");
      return [];
    }
  }

  Future<List<dynamic>> fetchRecommendedBooks() async {
    try {
      final response =
          await http.get(Uri.parse(ApiConstants.bookUrl + "recommend"));
      if (response.statusCode == 200) {
        print("Success with status code 200");

        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recommended books');
      }
    } catch (error) {
      print('Error fetching recommended books: $error');
      return [];
    }
  }

  Future<dynamic> bookById(String bookId) async {
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
        Uri.parse("${ApiConstants.bookUrl}status"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print("✅ Book fetched successfully.");
        return json
            .decode(response.body); // Should include book info + user status
      } else {
        print("❌ Failed with status code: ${response.statusCode}");
        throw Exception('Failed to load book');
      }
    } catch (error) {
      print('🚫 Error fetching book: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>> likeBook(String bookId, bool isLiked) async {
    String? userID = await api.getUserIdFromPrefs();

    final Map<String, dynamic> requestBody = {
      'isLiked': isLiked,
      'userID': userID,
    };

    final response = await http.patch(
      Uri.parse('${ApiConstants.bookUrl}like/$bookId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody), // Pass like/unlike info
    );

    print("Response = ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to like/unlike the book');
    }
  }

  Future<bool> AddToBookmark(String bookID, bool isbookmarked) async {
    String? userID = await api.getUserIdFromPrefs();

    Map<String, dynamic> requestBody = {
      "userId": userID,
      "isBookmarked": isbookmarked
    };

    var response = await http.post(
        Uri.parse(ApiConstants.bookUrl + "bookmark/$bookID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));



    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      bool isBookmarked = data["isBookmarked"];
      return isBookmarked;
    } else {

      throw Exception(
          "Error occured in bookmarking the book with status code = ${response.statusCode}");
    }
  }

  Future<bool> AddToReadList(String bookID, bool isRead) async {
    String? userID = await api.getUserIdFromPrefs();

    Map<String, dynamic> requestBody = {
      "userId": userID,
      "isRead": isRead
    };

    var response = await http.post(
        Uri.parse(ApiConstants.bookUrl + "readbook/$bookID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));



    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      bool isread = data["isRead"];
      return isread;
    } else {

      throw Exception(
          "Error occured in adding the book to read List with status code = ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> dislikeBook(
      String bookId, bool isDisliked) async {
    String? userID = await api.getUserIdFromPrefs();

    final Map<String, dynamic> requestBody = {
      'isDisliked': isDisliked,
      'userID': userID,
    };

    final response = await http.patch(
      Uri.parse('${ApiConstants.bookUrl}dislike/$bookId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody), // Pass like/unlike info
    );

    print("Response = ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to dislike/undislike the book');
    }
  }

  Future<List<dynamic>> GetComments(String bookId) async {
    var response =
        await http.get(Uri.parse(ApiConstants.commentUrl + "$bookId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("\nThe Response Body $data");
      return data;
    } else {
      throw Exception("Failed to Load Comments");
    }
  }

  Future<bool> AddComments(String bookId, String comment) async {
    String? userID = await api.getUserIdFromPrefs();

    final Map<String, dynamic> requestBody = {
      "userId": userID,
      "comment": comment
    };

    var response = await http.post(
        Uri.parse(ApiConstants.commentUrl + "$bookId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));

    var data = jsonDecode(response.body);

    print("Response status code = ${response.statusCode}");

    if (response.statusCode == 200) {
      return data['status'];
    } else {
      return data['status'];
    }
  }

  Future<List<dynamic>> fetchContinueReadingBooks() async {
    try {
      final response =
          await http.get(Uri.parse(ApiConstants.bookUrl + "continue"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load continue reading books');
      }
    } catch (error) {
      print('Error fetching continue reading books: $error');
      return [];
    }
  }
}
