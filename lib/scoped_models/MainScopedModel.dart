import 'package:scoped_model/scoped_model.dart';

import 'package:ucuz/scoped_models/ConnectedProductsScopedModel.dart';

class MainScopedModel extends Model with ConnectedProductsScopedModel, UserModel, ProductsModel, UtilityModel {
}
