import 'package:flutter/foundation.dart' as foundation;

import 'post.dart';
import 'post_repository.dart';

double _salesTaxRate = 0.06;
double _shippingCostPerItem = 7;

class AppStateModel extends foundation.ChangeNotifier {
  // All the available Posts.
  List<Post> _availablePosts = [];

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

  // Category get selectedCategory {
  //   return _selectedCategory;
  // }

  // Totaled prices of the items in the cart.
  // double get subtotalCost {
  //   return _PostsInCart.keys.map((id) {
  //     // Extended price for Post line
  //     return getPostById(id).price * _PostsInCart[id]!;
  //   }).fold(0, (accumulator, extendedPrice) {
  //     return accumulator + extendedPrice;
  //   });
  // }

  // Total shipping cost for the items in the cart.
  double get shippingCost {
    return _shippingCostPerItem *
        _PostsInCart.values.fold(0.0, (accumulator, itemCount) {
          return accumulator + itemCount;
        });
  }

  // Sales tax for the items in the cart
  // double get tax {
  //   return subtotalCost * _salesTaxRate;
  // }

  // Total cost to order everything in the cart.
  // double get totalCost {
  //   return subtotalCost + shippingCost + tax;
  // }

  // Returns a copy of the list of available Posts, filtered by category.
  List<Post> getPosts() {
    return List.from(_availablePosts);
    // if (_selectedCategory == Category.all) {
    //   return List.from(_availablePosts);
    // } else {
    //   return _availablePosts.where((p) {
    //     return p.category == _selectedCategory;
    //   }).toList();
    // }
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

  

  // Loads the list of available Posts from the repo.
  // void loadPosts() {
  //   _availablePosts = PostRepository.fetchPosts();
  //   notifyListeners();
  // }

  // void setCategory(Category newCategory) {
  //   _selectedCategory = newCategory;
  //   notifyListeners();
  // }
}
