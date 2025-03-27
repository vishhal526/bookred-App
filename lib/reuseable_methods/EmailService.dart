// import 'dart:math';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis/gmail/v1.dart' as gmail;
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
// import 'package:bookred/All_API_List/API_constants.dart';
//
// class EmailService {
//   final String clientId = ApiConstants.clientID;
//   final String clientSecret = ApiConstants.clientSecret;
//   final String refreshToken = ApiConstants.refreshToken;
//   final String senderEmail = 'bookred026@gmail.com'; // Replace with your email
//
//   // Generate a 6-digit verification code
//   String generateVerificationCode() {
//     return (Random().nextInt(900000) + 100000).toString();
//   }
//
//   // Function to obtain a new access token using refresh token
//   Future<String?> getAccessToken() async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://oauth2.googleapis.com/token'),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {
//           'client_id': clientId,
//           'client_secret': clientSecret,
//           'refresh_token': refreshToken,
//           'grant_type': 'refresh_token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         return jsonResponse['access_token'];
//       } else {
//         debugPrint('❌ Failed to get access token: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('❌ Exception in getAccessToken: $e');
//       return null;
//     }
//   }
//
//   // Function to create an authenticated client
//   Future<auth.AuthClient?> createAuthClient() async {
//     final accessToken = await getAccessToken();
//     if (accessToken == null) return null;
//
//     return auth.authenticatedClient(
//       http.Client(),
//       auth.AccessCredentials(
//         auth.AccessToken('Bearer', accessToken, DateTime.now().add(Duration(hours: 1)).toUtc()), // ✅ Fixed
//         null, // No refresh token needed since we fetch it manually
//         ['https://www.googleapis.com/auth/gmail.send'],
//       ),
//     );
//   }
//
//   // Encode email in Base64 URL-safe format
//   String encodeEmail(String emailContent) {
//     return base64UrlEncode(utf8.encode(emailContent)).replaceAll('=', '');
//   }
//
//   // Function to send email using Gmail API
//   // Future<bool> sendEmail(String recipientEmail, String code) async {
//   //   final authClient = await createAuthClient();
//   //   if (authClient == null) {
//   //     debugPrint('❌ Failed to create auth client. Email not sent.');
//   //     return false;
//   //   }
//   //
//   //   final gmailApi = gmail.GmailApi(authClient);
//   //   final message = gmail.Message()
//   //     ..raw = encodeEmail(
//   //         'To: $recipientEmail\n'
//   //             'From: $senderEmail\n'
//   //             'Subject: Your Verification Code\n'
//   //             '\n'
//   //             'Your 6-digit verification code is: $code');
//   //
//   //   try {
//   //     await gmailApi.users.messages.send(message, 'me');
//   //     debugPrint('✅ Email sent successfully to $recipientEmail!');
//   //     return true;
//   //   } catch (e) {
//   //     debugPrint('❌ Failed to send email: $e');
//   //     return false;
//   //   }
//   // }
//   Future<bool> sendEmail(String recipientEmail, String code) async {
//     final authClient = await createAuthClient();
//     if (authClient == null) {
//       debugPrint('❌ Failed to create auth client. Email not sent.');
//       return false;
//     }
//
//     final gmailApi = gmail.GmailApi(authClient);
//     final message = gmail.Message()
//       ..raw = encodeEmail(
//           'To: $recipientEmail\n'
//               'From: $senderEmail\n'
//               'Subject: Your Verification Code\n'
//               '\n'
//               'Your 6-digit verification code is: $code');
//
//     try {
//       await gmailApi.users.messages.send(message, 'me');
//       debugPrint('✅ Email sent successfully to $recipientEmail!');
//       return true;
//     } catch (e) {
//       debugPrint('❌ Failed to send email: $e');
//
//       // Check if error contains "550" (non-existent email)
//       if (e.toString().contains('550')) {
//         debugPrint('❌ Email address does not exist!');
//         return false;
//       }
//
//       return false; // Handle other errors
//     }
//   }
//
//
// }
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:bookred/All_API_List/API_constants.dart'; // You can keep your constants here if needed

class EmailService {
  final String senderEmail = 'bookred026@gmail.com'; // Your Gmail address
  final String appPassword = ApiConstants.password  ;    // Replace with your App Password from Google

  // Generate a 6-digit verification code
  String generateVerificationCode() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  // Send email using Gmail SMTP and App Password
  Future<bool> sendEmail(String recipientEmail, String code) async {
    final smtpServer = gmail(senderEmail, appPassword);

    final message = Message()
      ..from = Address(senderEmail, 'BookRed') // Sender info
      ..recipients.add(recipientEmail)         // Who you're sending to
      ..subject = 'Your Verification Code'
      ..text = 'Your 6-digit verification code is: $code';

    try {
      final sendReport = await send(message, smtpServer);

      debugPrint('✅ Email sent successfully to $recipientEmail!');
      debugPrint('Send report: $sendReport');

      return true;
    } on MailerException catch (e) {
      debugPrint('❌ Failed to send email: $e');

      // Optional: Print out detailed problems for debugging
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }

      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return false;
    }
  }
}
