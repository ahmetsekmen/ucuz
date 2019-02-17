import 'package:scoped_model/scoped_model.dart';

import 'dart:convert';
// import 'dart:async';
import 'package:ucuz/models/Product.dart';
import 'package:ucuz/models/User.dart';
import 'package:http/http.dart' as httpDart;
import 'package:ucuz/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectedProductsScopedModel extends Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductsScopedModel {
  bool _showFavorites = false;

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    print(_authenticatedUser.email);

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'http://cdn.kaltura.com/p/0/thumbnail/entry_id/1_psg64epw/quality/80/width//height//src_x//src_y//src_w/NaN/src_h/NaN/vid_sec/0.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final httpDart.Response response = await httpDart.post(
          'https://ucuzapp.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));
      // .then((httpDart.Response response) {
      //   if (response.statusCode != 200 || response.statusCode != 201) {
      //     _isLoading = false;
      //     notifyListeners();
      //     return false;
      //   }

      final Map<String, dynamic> responseData = json.decode(response.body);

      print('firebase responseData :' + responseData.toString());

      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners(); //scoped modeli haberdar ediyor.
      return true;
      // _selProductIndex=null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("ERROR GELDİ");
      return false;
    }

    // ).catchError((error) {
    //     _isLoading = false;
    //     notifyListeners();
    //     return false;
    //     print("ERROR GELDİ");
    //   });
  }

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  Product get selectedProduct {
    print('MEtod  selectedProduct :' + selectedProductId.toString());
    if (selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    print('selected product ID for update : ' + selectedProduct.id);
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'http://cdn.kaltura.com/p/0/thumbnail/entry_id/1_psg64epw/quality/80/width//height//src_x//src_y//src_w/NaN/src_h/NaN/vid_sec/0.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    return httpDart
        .put(
            'https://ucuzapp.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: jsonEncode(updateData))
        .then((httpDart.Response response) {
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);

      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;

    _products.removeAt(selectedProductIndex);
    _selProductId = null;

    notifyListeners();
    return httpDart
        .delete(
            'https://ucuzapp.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.token}')
        .then((httpDart.Response response) {
      _isLoading = false;

      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });

    _selProductId = null; //seçili bir product kalmadı.
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    print('fetchProducts çalıştı.');
    return httpDart.get('https://ucuzapp.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
        headers: {
          "Accept": "application/json"
        }).then<Null>((httpDart.Response response) {
      print(response);
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);

      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      productListData.forEach((String prodcutId, dynamic productData) {
        final Product product = Product(
          id: prodcutId,
          title: productData['title'],
          description: productData['description'],
          image: productData['image'],
          price: productData['price'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
        );
        fetchedProductList.add(product);
      });
      // print(fetchedProductList.first.id);
      _products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void selectProduct(String prodcutId) {
    _selProductId = prodcutId;
    print('_selProductIndex : ' + _selProductId);
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsScopedModel {

  User get user{
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    httpDart.Response response;
    if (mode == AuthMode.Login) {
      response = await httpDart.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDHxRvXQQm23n9C3C0JGruh--6R16VCb_Y',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await httpDart.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDHxRvXQQm23n9C3C0JGruh--6R16VCb_Y',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Hata oluştu!';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Auth Succeded';

      _authenticatedUser=User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken'] 
      );

    final SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setString('token', responseData['idToken']);
    prefs.setString('userEmail', email);
    prefs.setString('userId', responseData['localId']);

    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email bulunamadı';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'şifre geçerli değil';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Email zaten var';
    }

    _isLoading = false;
    notifyListeners();

    print(json.decode(response.body));
    return {'success': !hasError, 'message': message};
  }

  void AutoAuthenticate() async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    if (token !=null) {

      _authenticatedUser=User(
        id: prefs.getString('userEmail'),
        email: prefs.getString('userId'),
        token: token
      );

      notifyListeners();

    }
  }


}

class UtilityModel extends ConnectedProductsScopedModel {
  bool get isLoading {
    return _isLoading;
  }
}
