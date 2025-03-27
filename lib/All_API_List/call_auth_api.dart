import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:bookred/All_API_List/API_constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  ApiConstants api = ApiConstants();

  Future<int> checkUserExist(
      {String? username, String? email, String? phoneNumber}) async {
    try {
      if (username == null && email == null) {
        throw Exception(
            "At least one parameter (username, email, or phoneNumber) must be provided.");
      }

      final queryParams = {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.authUrl + "userExits"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(queryParams),
      );

      print("Response code == ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists']; // 1 if exists, 0 if not
      } else {
        throw Exception("Failed to check user existence");
      }
    } catch (error) {
      print("Error checking user existence: $error");
      return -1; // Return -1 to indicate an error
    }
  }

  Future<int> changeUsername(String username) async {
    String? userID = await api.getUserIdFromPrefs();

    var response = await http.put(
        Uri.parse(ApiConstants.userUrl + "updateName/$userID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"newName": username}));

    print("Response status code == ${response.statusCode}");

    if (response.statusCode == 200) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> changeEmail(String email) async {
    String? userID = await api.getUserIdFromPrefs();

    var response = await http.put(
        Uri.parse(ApiConstants.userUrl + "updateEmail/$userID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"newEmail": email}));

    print("Response status code == ${response.statusCode}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String updatedemail = data["user"]["updatedUser"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email',
          updatedemail);
      return 1;
    } else {
      return 0;
    }
  }

  Future<String> signin(
      {required String name,
      required String username,
      required String password,
      String? email,
      String? phoneNumber}) async {
    try {
      if (email == null && phoneNumber == null) {
        throw Exception('Either email or phoneNumber must be provided.');
      }

      Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
        'name': name,
        'email': email,
        // if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };

      print("Name: $name");
      print("Username: $username");
      print("Password: $password");
      print("Email: $email");

      final response = await http.post(
        Uri.parse(ApiConstants.authUrl + "signIn"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Success with status code 200");
        return "Success";
      } else {
        final responseData = jsonDecode(response.body);
        print(
            "Failed to sign in with status code: ${response.statusCode} and error is: ${response.body}");
        return responseData["message"];
      }
    } catch (error) {
      print('Error signing in: $error');
      return "Error Signing in due to network Issue";
    }
  }

  Future<String> login(
      {String? username, required String password, String? email}) async {
    try {
      if (email == null && username == null) {
        throw Exception('Either email or username must be provided.');
      }

      Map<String, dynamic> requestBody = {
        "loginId": username ?? email,
        'password': password,
        // if (email != null) 'email': email,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.authUrl + "login"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String token = responseData['token'];

        // Decode the JWT token to extract userId
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['userId'];
        String loggedInUsername = decodedToken['username'];
        String? pfp = decodedToken['pfp'];
        String email = decodedToken['email'];

        print("\nLogged IN");
        // Save userId to SharedPreferences
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setString('user_id', userId);
        print("\nUserID = $userId");
        sharedPref.setString('username', loggedInUsername);
        print("\nUserName = $username");
        sharedPref.setString('pfp', pfp ?? '');
        print("\nUser Image link = $pfp");
        sharedPref.setString('email', email);
        print("\nUser email = $email");
        return "S";
      } else if (response.statusCode == 401) {
        // ✅ Use response.statusCode
        final responseData = json.decode(response.body);
        String error = responseData['message']; // Extract the error message
        return error;
      } else {
        throw Exception('Failed to login');
      }
    } catch (error) {
      print('Error fetching continue reading books: $error');
      return "Error Loggin in due to network Issue";
    }
  }

  Future<int> resetPassword(
      {required String email, required String password}) async {
    try {
      final key = encrypt.Key.fromUtf8(ApiConstants.aesKey);
      final iv = encrypt.IV.fromSecureRandom(16);

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(password, iv: iv);

      final encryptedIV = base64Encode(iv.bytes);
      final encryptedPassword = base64Encode(encrypted.bytes);

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'encryptedPassword': encryptedPassword,
        'encryptedIV': encryptedIV,
        'email': email,
      };

      // Send both encrypted password and IV in the request body
      final response = await http.post(
        Uri.parse(ApiConstants.authUrl + "reset-password"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print("Response Status = ${response.statusCode}");

      if (response.statusCode == 200) {
        return 1; // Success
      } else {
        throw Exception('Failed to reset password');
      }
    } catch (error) {
      print('Error resetting the password: $error');
      return 0; // Failure
    }
  }
}
