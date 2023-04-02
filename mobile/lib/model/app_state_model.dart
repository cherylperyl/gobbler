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
  // The currently selected category of Posts.
  // Category _selectedCategory = Category.all;

  // The IDs and quantities of Posts currently in the cart.
  final _PostsInCart = <int, int>{};

  Map<int, int> get PostsInCart {
    return Map.from(_PostsInCart);
  }

  // Total number of items in the cart.
  int get totalCartQuantity {
    return _PostsInCart.values.fold(0, (accumulator, value) {
      return accumulator + value;
    });
  }



  // Returns a copy of the list of available Posts, filtered by category.
  List<Post>? getPosts() {
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
  

  // Search the Post catalog
  // List<Post> search(String searchTerms) {
  //   return getPosts().where((Post) {
  //     return Post.name.toLowerCase().contains(searchTerms.toLowerCase());
  //   }).toList();
  // }

  // Adds a Post to the cart.
  void addPostToCart(int PostId) {
    if (!_PostsInCart.containsKey(PostId)) {
      _PostsInCart[PostId] = 1;
    } else {
      _PostsInCart[PostId] = _PostsInCart[PostId]! + 1;
    }

    notifyListeners();
  }

  // Removes an item from the cart.
  void removeItemFromCart(int PostId) {
    if (_PostsInCart.containsKey(PostId)) {
      if (_PostsInCart[PostId] == 1) {
        _PostsInCart.remove(PostId);
      } else {
        _PostsInCart[PostId] = _PostsInCart[PostId]! - 1;
      }
    }

    notifyListeners();
  }

  // Returns the Post instance matching the provided id.
  // Post getPostById(int id) {
  //   return _availablePosts.firstWhere((p) => p.id == id);
  // }

  // Removes everything from the cart.
  void clearCart() {
    _PostsInCart.clear();
    notifyListeners();
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
      
      print(_availablePosts);
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
  Future<Post?> hidePost(num postId) async {
    Post? post = await PostRepository.hidePost(postId);
    return post;
  }
}
