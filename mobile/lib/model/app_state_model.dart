import 'package:flutter/foundation.dart' as foundation;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_repository.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'post.dart';
import 'post_repository.dart';

import 'user.dart';
import 'user_repository.dart';

double _salesTaxRate = 0.06;
double _shippingCostPerItem = 7;

class AppStateModel extends foundation.ChangeNotifier {
  // All the available Posts.
  List<Post> _availablePosts = [];
  List<Post> _userCreatedPosts = [];
  List<Post> _userRegisteredPosts = [];
  Map<num, int> _userRegisteredPostsIds = Map<num,int>();
  LocationData? _currentLocation;
  User? _user;
  LocationRepository locationRespository = LocationRepository();

  List<Post>? getPosts() {
    if (_availablePosts.isEmpty) {
      return null;
    }
    return List.from(_availablePosts);
  }
  List<Post> getUserCreatedPosts() {
    return List.from(_userCreatedPosts);
  }
  List<Post> getUserRegisteredPosts() {
    return List.from(_userRegisteredPosts);
  }
  Map<num, int> getUserRegisteredPostsIds() {
    return _userRegisteredPostsIds;
  }


  LocationData? getLoc() {
    return _currentLocation;
  }
  User? getUser() {
    return _user;
  }
  User setUserToPremium() {
    _user!.isPremium = true;
    notifyListeners();
    return _user!;
  }

  void loadPosts() async {
    _currentLocation = await locationRespository.getLoc();
    print(_currentLocation);
    notifyListeners();
    int user_id = 0;
    if (_user != null) {
      user_id = _user!.userId;
    }
    if (_currentLocation != null) {
      double long = _currentLocation!.longitude!, lat = _currentLocation!.latitude!; 
      
      _availablePosts = await PostRepository.fetchPosts(long, lat, user_id);  
      
      print('available posts $_availablePosts');
    } else {
      _availablePosts = await PostRepository.fetchPosts(1.2993038848815959, 103.84554001541605, user_id);  
    }

    notifyListeners();
  }

  // void updateLocation() async {
  //   _currentLocation = await locationRespository.getLoc();
  //   notifyListeners();
  // }

  Future<void> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString('user');
    String? bearer = prefs.getString('bearerToken');
    print('userStr $userStr');
    if (userStr != null) {
      _user = User.fromJson(jsonDecode(userStr));
      print('_user $_user');
      print('bearer $bearer');
      if (bearer != null && _user != null) {
        _userCreatedPosts = await PostRepository.fetchCreatedPosts(_user!.userId);
        print('_userCreatedPosts $_userCreatedPosts');
        final reservationList = await PostRepository.fetchRegisteredPosts(_user!.userId);
        print('reservationList $reservationList');
        _userRegisteredPosts = [];
        _userRegisteredPostsIds.clear();
        for (var i = 0; i < reservationList.length; i++) {
          _userRegisteredPosts.add(Post.fromJson(reservationList[i]['post']));
          _userRegisteredPostsIds[reservationList[i]['post_id']] = reservationList[i]['reservation_id'];
        }
        print('userRegisteredPosts $_userRegisteredPosts');
        print('userRegisteredPostsIds $_userRegisteredPostsIds');
      }
      notifyListeners();  
    }
      
    notifyListeners();
  }

  Future<void> getUpdatedUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final bearer = prefs.getString('bearerToken');
    _user = await UserRepository.getUserData(bearer);
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      // Map<String, dynamic> userJson = User.toJson();
      // print('jsonEncode ${jsonEncode(userJson)}');
      prefs.setString('user', jsonEncode(_user!));
    }
    notifyListeners();
  }
  // possibly change to call one endpoint only
  Future<void> loginUser(String email, String password) async {
    _user = await UserRepository.loginUser(email, password);
    
    notifyListeners();
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      _userCreatedPosts = await PostRepository.fetchCreatedPosts(_user!.userId);
      final reservationList = await PostRepository.fetchRegisteredPosts(_user!.userId);
      print('reservationList $reservationList');
      _userRegisteredPosts = [];
      _userRegisteredPostsIds.clear();
      for (var i = 0; i < reservationList.length; i++) {
         _userRegisteredPosts.add(Post.fromJson(reservationList[i]['post']));
        _userRegisteredPostsIds[reservationList[i]['post_id']] = reservationList[i]['reservation_id'];
      }
      print('userRegisteredPosts $_userRegisteredPosts');
      print('userRegisteredPostsIds $_userRegisteredPostsIds');
    }
    notifyListeners();
  }
  Future<void> signupUser(String username, String email, String password) async  {
    bool success = await UserRepository.signupUser(username, email, password);
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    prefs.remove('bearerToken');
    _user = null;
    notifyListeners();
  }

  Future<bool> reservePost(num postId, int userId) async {
    bool success = await PostRepository.reservePost(postId, userId);
    if (success) {
      final reservationList = await PostRepository.fetchRegisteredPosts(_user!.userId);
      print('reservationList $reservationList');
      _userRegisteredPosts = [];
      _userRegisteredPostsIds.clear();
      for (var i = 0; i < reservationList.length; i++) {
         _userRegisteredPosts.add(Post.fromJson(reservationList[i]['post']));
        _userRegisteredPostsIds[reservationList[i]['post_id']] = reservationList[i]['reservation_id'];
      }
      print('userRegisteredPosts $_userRegisteredPosts');
      print('userRegisteredPostsIds $_userRegisteredPostsIds');
      notifyListeners();
      
    }
    return success;
  }

  Future<bool> cancelReservation(int reservationId) async {
  bool success = await PostRepository.cancelReservation(reservationId);
  if (success) {
    final reservationList = await PostRepository.fetchRegisteredPosts(_user!.userId);
    print('reservationList $reservationList');
    _userRegisteredPosts = [];
    _userRegisteredPostsIds.clear();
    for (var i = 0; i < reservationList.length; i++) {
      _userRegisteredPosts.add(Post.fromJson(reservationList[i]['post']));
      _userRegisteredPostsIds[reservationList[i]['post_id']] = reservationList[i]['reservation_id'];
    }
    print('userRegisteredPosts $_userRegisteredPosts');
    print('userRegisteredPostsIds $_userRegisteredPostsIds');
    notifyListeners();
  }
  return success;
  }


  Future<Post?> uploadPost(
    String title, 
    String locationDesc, 
    String servings,
    String expiryTime,
    int userId,
    XFile image,
    LocationData locationData
  ) async {
    final post = await PostRepository.uploadPost(
      title, 
      locationDesc, 
      servings, 
      expiryTime, 
      userId, 
      image, 
      locationData
    );
    _userCreatedPosts = await PostRepository.fetchCreatedPosts(userId);
    notifyListeners();
    return post;
  }

  Future<Post?> updatePost(
  String title, 
  String locationDesc, 
  String servings,
  String expiryTime,
  int userId,
  XFile image,
  LocationData locationData,
  num postId,
  ) async {
    final post = await PostRepository.updatePost(
      postId, 
      title, 
      locationDesc, 
      servings, 
      expiryTime, 
      userId, 
      image, 
      locationData,
    );
    _userCreatedPosts = await PostRepository.fetchCreatedPosts(userId);
    notifyListeners();
    return post;
  }
  Future<Post?> hidePost(num postId, int userId) async {
    Post? post = await PostRepository.hidePost(postId);
    _userCreatedPosts = await PostRepository.fetchCreatedPosts(userId);
    notifyListeners();
    return post;
  }
}
