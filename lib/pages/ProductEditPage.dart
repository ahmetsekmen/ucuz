import 'package:flutter/material.dart';
import 'package:ucuz/scoped_models/MainScopedModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ucuz/models/Product.dart';
import 'package:ucuz/widgets/helpers/ensure_visible.dart';

class ProductEditPage extends StatefulWidget {
  // final MainScopedModel model;

  // ProductEditPage(this.model);

  @override
  State < StatefulWidget > createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State < ProductEditPage > {
  final Map < String,
  dynamic > _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };

  final GlobalKey < FormState > _formKey = GlobalKey < FormState > ();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant < MainScopedModel > (
      builder: (BuildContext context, Widget child, MainScopedModel model) {
        // print(model.selectedProduct.title.toString());

        final Widget pageContent =
          _buildPageContent(context, model.selectedProduct);

        print('selected Product Index : ' +
          model.selectedProductIndex.toString());

        return model.selectedProductIndex == -1 ?
          pageContent :
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('Edit Product'),
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  print('geriye basıldı');
                  model.selectProduct(
                    model.allProducts[model.selectedProductIndex].id);
                  Navigator.pop(context, true);
                }),
            ),
            body: pageContent,
          );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());

        // print('onTap');
      },
      // onPanCancel:(){
      //   print('onPanCancel');
      // },
      // onTapCancel:(){
      //   print('onTapCancel');
      // },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: < Widget > [
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),

              // GestureDetector(
              //   onTap: _submitForm,
              //   child: Container(
              //     color: Colors.green,
              //     padding: EdgeInsets.all(5.0),
              //     child: Text('My Button'),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant < MainScopedModel > (
      builder: (BuildContext context, Widget child, MainScopedModel model) {
        return model.isLoading ?
          Center(
            child: CircularProgressIndicator(),
          ) :
          RaisedButton(
            child: Text('Save'),
            textColor: Colors.white,
            onPressed: () => _submitForm(
              model.addProduct,
              model.updateProduct,
              model.selectProduct,
              model.selectedProductIndex),
          );
      },
    );
  }

  void _submitForm(
    Function addProduct, Function updateProduct, Function setSelectedProduct,
    [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        _formData['price'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/products')
            .then((_) => setSelectedProduct(null));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Bir hata oluştu"),
                content: Text("Lütfen tekrar deneyin"),
                actions: < Widget > [
                  FlatButton(
                    child: Text("Tamam"),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
        }
      });

      // .then(()=>
      //   Navigator.pushReplacementNamed(context, '/products')
      //   .then((_) => setSelectedProduct(null)));
    } else {
      updateProduct(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        _formData['price'],
      );
    }
    // Navigator.pushReplacementNamed(context, '/products')
    //   .then((_) => setSelectedProduct(null));
  }

  Widget _buildPriceTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Product Price'),
        initialValue: product == null ? '' : product.price.toString(),
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'Fiyat rakamlardan oluşan zorunlu bir alandır.';
          }
        },
        onSaved: (String value) {
          _formData['price'] = double.parse(value);
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        maxLines: 4,
        decoration: InputDecoration(labelText: 'Ürün Açıklama'),
        initialValue: product == null ? '' : product.description,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 10) {
            return 'Açıklama on karakterden fazla olmak zorundadır.';
          }
        },
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }

  Widget _buildTitleTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Ürün Başlığı'),
        initialValue: product == null ? '' : product.title,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 5) {
            return 'Başlık en az beş karakter olmalıdır.';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }
}