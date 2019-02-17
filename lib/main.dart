import 'package:flutter/material.dart';
import 'package:ucuz/pages/AuthPage.dart';
import 'package:ucuz/pages/ProductsPage.dart';
import 'package:ucuz/pages/ProductsAdminPage.dart';

// import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:ucuz/scoped_models/MainScopedModel.dart';
import 'package:ucuz/pages/ProductPage.dart';
import 'package:ucuz/models/Product.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainScopedModel _model = MainScopedModel();

  @override
  void initState() {
    _model.AutoAuthenticate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainScopedModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.blueAccent),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant(
                builder: (BuildContext context, Widget child, MainScopedModel model) {
                  return model.user == null ? AuthPage() : ProductsPage(_model);
                },
              ),
          '/products': (BuildContext context) => ProductsPage(_model),
          '/admin': (BuildContext context) => ProductsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          print('onGenerateRoute a geldi');
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            print('onGenerateRoute  pathElements[1] == "product"');
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => ProductPage(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          print('onUnknownRoute a geldi');
          return MaterialPageRoute(
              builder: (BuildContext context) => ProductsPage(_model));
        },
      ),
    );
  }
}
