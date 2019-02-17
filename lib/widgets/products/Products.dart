import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './ProductCard.dart';
// import '../../models/Product.dart';
import 'package:ucuz/models/Product.dart';
import 'package:ucuz/scoped_models/MainScopedModel.dart';


class Products extends StatelessWidget {

  Widget _buildProductsList(List < Product > products) {
    Widget productCards;
    print(products.length.toString());
    // print(index.toString());
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
        ProductCard(products[index], index),
        itemCount: products.length
      );
    } else {
      print('productCards boş container yazdık');
      productCards = Container();
    }

    return productCards;
  }




  @override
  Widget build(BuildContext context) {
    print(' Ürün widget ı build oluyor.');
    return ScopedModelDescendant(builder: (BuildContext context, Widget child, MainScopedModel model) {
      return _buildProductsList(model.displayedProducts);
    }, );
  }

}