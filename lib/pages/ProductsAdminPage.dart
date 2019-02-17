import 'package:flutter/material.dart';
import 'package:ucuz/pages/ProductEditPage.dart';
import 'package:ucuz/pages/ProductListPage.dart';
import 'package:ucuz/scoped_models/MainScopedModel.dart';

class ProductsAdminPage extends StatelessWidget{

  final MainScopedModel model;

  ProductsAdminPage(this.model);
  
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Seçim'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Bütün Ürünler'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          )
        ],
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Ürünleri Yönet'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Ürün Oluştur',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'Benim Ürünlerim',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[ProductEditPage(), ProductListPage(model)],
        ),
      ),
    );
  }

}