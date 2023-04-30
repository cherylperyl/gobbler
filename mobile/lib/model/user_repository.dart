import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static Future<User> loginUser(String email, String password) async {
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/user/loginuser');
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'username': email,
        'password': password
      }),
      headers: { "Content-Type": "application/json" });
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      final headers = response.headers;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('bearerToken', headers['authorization']!);
      print('bearerToken ${headers['authorization']}');
      print('userJson = ${data}');
      prefs.setString('user', response.body);

      return user;
    }
    return Future.error('Unable to login user');
  }
  static Future<bool> signupUser(String username, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final fcm = prefs.getString('messagingToken');
    print('fcm $fcm');
    var url = Uri.http("${dotenv.env['BASE_API_URL']}",'/user/createaccount');
    var jsonBody = jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'username': username,
        'fcmToken': '$fcm'
    });
    print(url);
    print(jsonBody);
    var response = await http.post(
      url,
      body: jsonBody,
      headers: { "Content-Type": "application/json" }
    );
    print('here');
    print('response body ${response.body}');
    if (response.statusCode == 200) {
      print(response.body);
      return Future.value(true);
    }
    return Future.error('Unable to signup user');
  }
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearerToken');
  }
  static Future<User?> getUserData(bearer) async {
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5001",'/getUser');
    var response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer: $bearer"
      }
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      return user;
    }
    return null;
  }

}
