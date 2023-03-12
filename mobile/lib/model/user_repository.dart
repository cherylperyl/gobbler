import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'post.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static Future<String> loginUser(String email, String password) async {
    var url = Uri.http(dotenv.env['BASE_API_URL']!,'/login');
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'username': email,
        'password': password
      }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bearerToken', data['bearer_token']);

      return data['bearer_token'];
    }
    return Future.error('Unable to login user');
  }

    static Future<bool> logoutUser() async {
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
    return true;
  }
}
