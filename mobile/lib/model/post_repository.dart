import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post.dart';
import 'package:http/http.dart' as http;

class PostRepository {
  static Future<List<Post>> fetchPosts() async {
    var url = Uri.http(dotenv.env['BASE_API_URL']!,'/posts');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      List<Post> results = [];
      dataList.forEach((el) => {
        results.add(Post.fromJson(el))
      });
      return results;
    }
    return [];
  }

  static Future<void> reserveSnack(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? bearer = prefs.getString('bearerToken');
    var url = Uri.http(dotenv.env['BASE_API_URL']!,'/reserve');
    // short circuit
    // should fetch data again from 
    return ;
    var response = await http.post(
      url,
      body: jsonEncode(
        {
          "postId": postId
        }
      ),
      headers: {
        "Authorization": 'Bearer $bearer'
      }
    );
    if (response.statusCode == 200) {
      final dataList = jsonDecode(response.body);
      List<Post> results = [];
      dataList.forEach((el) => {
        results.add(Post.fromJson(el))
      });

    }
  }

}