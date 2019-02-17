import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:ucuz/widgets/products/PriceTag.dart';
import './AddressTag.dart';
import 'package:ucuz/widgets/ui_elements/TitleDefault.dart';

import 'package:ucuz/models/Product.dart';
import '../../scoped_models/MainScopedModel.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: < Widget > [
          TitleDefault(product.title),
          SizedBox(
            width: 8.0,
          ),
          PriceTag(product.price.toString())
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant < MainScopedModel > (
      builder: (BuildContext context, Widget child, MainScopedModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: < Widget > [
            IconButton(
              icon: Icon(Icons.info),
              color: Theme.of(context).accentColor,
              onPressed: () => Navigator.pushNamed < bool > (
                context, '/product/' + model.allProducts[productIndex].id),
            ),
            IconButton(
              icon: Icon(model.allProducts[productIndex].isFavorite ?
                Icons.favorite :
                Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(model.allProducts[productIndex].id);
                model.toggleProductFavoriteStatus();
              },
            )
          ],
        );
      });
  }


  @override Widget build(BuildContext context) {
    print('product cartta');
    return Card(
      child: Column(
        children: < Widget > [
          FadeInImage(
            image: NetworkImage(product.image),
            placeholder: AssetImage('assets/food.jpg'),
            height: 300.0,
            fit: BoxFit.cover,
          ),
          _buildTitlePriceRow(),
          AddressTag('Üsküdar Altünizade'),
          Text(product.userEmail),
          _buildActionButtons(context)
        ],
      ),
    );
  }
}