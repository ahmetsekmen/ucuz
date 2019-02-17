import 'package:flutter/material.dart';
import 'package:ucuz/scoped_models/MainScopedModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ucuz/pages/ProductEditPage.dart';


class ProductListPage extends StatefulWidget {
final MainScopedModel model;

ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProdcutListPageState();
  }

}

class _ProdcutListPageState extends State<ProductListPage>{

  @override
  initState(){
    widget.model.fetchProducts(); //bu sayfayı yükleyincede de proıdcyutlkarı fetchy ediyoruz.

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainScopedModel>(
      builder: (BuildContext context, Widget child, MainScopedModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allProducts[index].title),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectProduct(model.allProducts[index].id);
                  model.deleteProduct();
                } else if (direction == DismissDirection.startToEnd) {
                  print('Swiped start to end');
                } else {
                  print('Other swiping');
                }
              },
              background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image),
                    ),
                    title: Text(model.allProducts[index].title),
                    subtitle:
                        Text('\$${model.allProducts[index].price.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context, int index, MainScopedModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.allProducts[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProductEditPage();
            },
            
          ),
          
        );
      },
    );
  }


}