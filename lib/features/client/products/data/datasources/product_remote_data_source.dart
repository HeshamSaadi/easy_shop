import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/client/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> getProductDetails(String slug);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._api);

  final ApiConsumer _api;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _api.get(EndPoints.clientProducts);
    return ResponseReader.list(response).map(ProductModel.fromJson).toList();
  }

  @override
  Future<ProductModel> getProductDetails(String slug) async {
    final response = await _api.get(EndPoints.clientProductDetails(slug));
    return ProductModel.fromJson(ResponseReader.object(response));
  }
}
