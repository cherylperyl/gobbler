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
  List<Post> getPosts() {
    return List.from(_availablePosts);
  }
  List<Post> getUserCreatedPosts() {
    List<Post> mockPosts = [
        Post(
          userId: 22, 
          postId: 22, 
          title: "Chicken Rice", 
          imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
          locationDescription: "My mother's house", 
          locationLatitude: 2, 
          locationLongitude: 2, 
          availableReservations: 22, 
          totalReservations: 23, 
          createdAt: DateTime.parse("2023-04-28T06:43:24"), 
          timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
          isAvailable: true
        ),
        Post(
          userId: 22, 
          postId: 23, 
          title: "Nasi Lemak", 
          imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
          locationDescription: "My mother's house", 
          locationLatitude: 2, 
          locationLongitude: 2, 
          availableReservations: 22, 
          totalReservations: 23, 
          createdAt: DateTime.parse("2023-04-28T06:43:24"), 
          timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
          isAvailable: true
          )
    ];
    return List.from(mockPosts);
    // return List.from(_userCreatedPosts);
  }
  List<Post> getUserRegisteredPosts() {
    List<Post> mockPosts = [
        Post(
          userId: 23, 
          postId: 22, 
          title: "Chicken Rice", 
          imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
          locationDescription: "My mother's house", 
          locationLatitude: 2, 
          locationLongitude: 2, 
          availableReservations: 22, 
          totalReservations: 23, 
          createdAt: DateTime.parse("2023-04-28T06:43:24"), 
          timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
          isAvailable: true
        ),
        Post(
          userId: 23, 
          postId: 23, 
          title: "Nasi Lemak", 
          imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
          locationDescription: "My mother's house", 
          locationLatitude: 2, 
          locationLongitude: 2, 
          availableReservations: 22, 
          totalReservations: 23, 
          createdAt: DateTime.parse("2023-04-28T06:43:24"), 
          timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
          isAvailable: true
          )
    ];
    return List.from(mockPosts);
    return List.from(_userRegisteredPosts);
  }
  List<int> getUserRegisteredPostsIds() {
    List<Post> mockRegisteredPosts = [
      Post(
        userId: 23, 
        postId: 22, 
        title: "Chicken Rice", 
        imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
        locationDescription: "My mother's house", 
        locationLatitude: 2, 
        locationLongitude: 2, 
        availableReservations: 22, 
        totalReservations: 23, 
        createdAt: DateTime.parse("2023-04-28T06:43:24"), 
        timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
        isAvailable: true
      ),
      Post(
        userId: 23, 
        postId: 23, 
        title: "Nasi Lemak", 
        imageUrl: "https://www.innit.com/public/recipes/images/1033246--742330450-en-US-0_s1000.jpg", 
        locationDescription: "My mother's house", 
        locationLatitude: 2, 
        locationLongitude: 2, 
        availableReservations: 22, 
        totalReservations: 23, 
        createdAt: DateTime.parse("2023-04-28T06:43:24"), 
        timeEnd: DateTime.parse("2023-04-28T06:43:24"), 
        isAvailable: true
        )
    ];
    return mockRegisteredPosts.map((post) => post.postId).toList();
    return _userRegisteredPosts.map((post) => post.postId).toList();
  }

  LocationData? getLoc() {
    return _currentLocation;
  }
  User? getUser() {
    return User(
      userId: 2,
      isPremium: true,
      username: "bobby",
      dateCreated: DateTime.now(),
      lastUpdated: null,
      email: "bobby@gmail.com"
    );
    return _user;
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
    _availablePosts = await PostRepository.fetchPosts();
    notifyListeners();
  }

  void updateLocation() async {
    _currentLocation = await locationRespository.getLoc();
    notifyListeners();
  }

  Future<void> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    if (user != null) {
      _user = User.fromJson(jsonDecode(user));
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
    String? bearer = await UserRepository.loginUser(email, password);
    _user = await UserRepository.getUserData(bearer);
    
    if (_user != null) {
      _userCreatedPosts = await PostRepository.fetchCreatedPosts(_user!.userId);
      _userRegisteredPosts = await PostRepository.fetchRegisteredPosts(_user!.userId);
      final prefs = await SharedPreferences.getInstance();
      // print('jsonEncode ${jsonEncode(userJson)}');
      prefs.setString('user', jsonEncode(_user!));
    }
    notifyListeners();
  }
  Future<void> signupUser(String username, String email, String password) async  {
    bool success = await UserRepository.signupUser(username, email, password);
  }

  Future<void> logoutUser() async {
    await UserRepository.logoutUser();
    _user = null;
    notifyListeners();
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
    return post;
  }
}
