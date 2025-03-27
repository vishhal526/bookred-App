import 'dart:convert';
import 'package:bookred/All_API_List/API_constants.dart';
import 'package:http/http.dart' as http;

class PhoneService {
  final String numberId;
  final String accessToken;
  late final String apiUrl;

  PhoneService()
      : numberId = ApiConstants.phoneNumbnerId,
        accessToken = ApiConstants.token.replaceAll(RegExp(r'\s+'), '') {
    apiUrl = "https://graph.facebook.com/v21.0/$numberId/messages";
  }

  Future<bool> sendOTP(String recipientNumber, String message) async {
    try {
      // Debugging
      print("API URL: $apiUrl");
      print("Number ID: $numberId");
      print("Access Token: '$accessToken'");

      Map<String, String> headers = {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      };

      print("Headers: $headers"); // Debug headers

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          "messaging_product": "whatsapp",
          "to": recipientNumber,
          "type": "text",
          "text": {"body": message},
        }),
      );

      if (response.statusCode == 200) {
        print("Message sent successfully!");
        return true;
      } else {
        print("Failed to send message: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sending message: $e");
      return false;
    }
  }
}
