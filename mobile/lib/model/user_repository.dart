import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  // change to one endpoint only
  static Future<String> loginUser(String email, String password) async {
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5401",'/login');
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'username': email,
        'password': password
      }));
    if (response.statusCode == 200) {
      final headers = response.headers;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bearerToken', headers['authorization']!);
      return headers['authorization']!;
    }
    return Future.error('Unable to login user');
  }
  static Future<bool> signupUser(String username, String email, String password) async {
    // may need to change to send the 
    var url = Uri.http("${dotenv.env['BASE_API_URL']!}:5401",'/account/create');
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password
      }));
    if (response.statusCode == 200) {
      return Future.value(true);
    }
    return Future.error('Unable to signup user');
  }
  static Future<void> logoutUser() async {
    // var url = Uri.http(dotenv.env['BASE_API_URL']!,'/login');
    // var response = await http.post(
    //   url,
    //   body: jsonEncode(<String, String>{
    //     'username': email,
    //     'password': password
    //   }));
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setString('bearerToken', data['bearer_token']);

    //   return data['bearer_token'];
    // }
    // return Future.error('Unable to login user');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearerToken');
  }
  // probably move to one function under loginUser
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
