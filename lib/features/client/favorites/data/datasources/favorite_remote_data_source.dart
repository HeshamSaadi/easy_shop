import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/products/data/models/product_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<ProductModel>> getFavorites();

  Future<void> addFavorite(int productId);

  Future<void> removeFavorite(int productId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  const FavoriteRemoteDataSourceImpl(this._api);

  static const String _productIdKey = 'product_id';
  static const String _productKey = 'product';

  final ApiConsumer _api;
  @override
  Future<List<ProductModel>> getFavorites() async {
    final response = await _api.get(EndPoints.clientFavorites);
    return ResponseReader.list(response)
        .map((item) => ProductModel.fromJson(parseMap(item[_productKey])))
        .where((product) => product.id != 0)
        .toList();
  }

  @override
  Future<void> addFavorite(int productId) async {
    await _api.post(
      EndPoints.clientFavoriteStore,
      data: {_productIdKey: productId},
    );
  }

  @override
  Future<void> removeFavorite(int productId) async {
    await _api.delete(
      EndPoints.clientFavoriteDestroy,
      data: {_productIdKey: productId},
    );
  }
}
