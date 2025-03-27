// lib/api_constants.dart
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static String aesKey = "my32lengthsupersecretnooneknows!";
  static String clientID =
      "1037557480853-6jjq3u1roa06ab1vnfkqt5ognvn27lhu.apps.googleusercontent.com";
  static String clientSecret = "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";
  static String refreshToken =
      "1//0gS6-MDxvQyhgCgYIARAAGBASNwF-L9IrN52I6FMA4Yr9n3ezSkBwc6WMN90cBAr2xtw_r4A7YuQo32ex4C9YWuhTrW3IfKRsCuQ";
  static String password = 'kptf zvqx txjy qxkb';
  static String token =
      "EAANtxT6NzhIBO6WanPQ67qRq9YEgEfl17yrrTTN3dR3bMCZA4cEANERxXAb3spfFrLWXCz6rZAF2h4dWx3n61fcjZCJfpNRajnPhx2cEsTSSC31oChczMkCQsHCSubhVzBZA1FaaziiECwmU9IgluXy0pq8YghNQHRfk1fAknmDMSJvNoDvzjhzAbXz3l1gZAHwd834FoqNzQynX7F3uH9dAolx09qZCwhNgMZD";
  static String phoneNumbnerId = "545441038656472";

  static String mainUrl = 'http://192.168.0.106:3030/';
  // static String mainUrl = 'http://10.20.50.137:3030/';
  // static String mainUrl = 'http://192.168.4.74:3030/';
  // static String mainUrl = 'http://localhost:3030/';

  // static String mainUrl = 'https://205a-103-70-32-90.ngrok-free.app/';
  static String bookUrl = '${mainUrl}book/';
  static String authorUrl = '${mainUrl}author/';
  static String publisherUrl = '${mainUrl}publisher/';
  static String commentUrl = '${mainUrl}book/comments/';
  static String genreUrl = '${mainUrl}genre/';
  static String authUrl = '${mainUrl}auth/';
  static String userUrl = '${mainUrl}user/';

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('user_id'); // Make sure you saved the userID with this key
  }

  Future<String?> getUserNameFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('username'); // Make sure you saved the userID with this key
  }

  Future<String?> getEmailFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('email'); // Make sure you saved the userID with this key
  }

  Future<String?> getUserPhotoFromPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("pfp");
  }

  Future<List<String?>> getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String?>? userData;
    userData!.add(pref.getString('username'));
    userData.add(pref.getString('username'));
    return userData;
  }
}
