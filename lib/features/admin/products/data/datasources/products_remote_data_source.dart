import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/multipart_helper.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/admin/products/data/models/product_model.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> getProduct(String slug);

  Future<ProductModel> createProduct(ProductParams params);

  Future<ProductModel> updateProduct(String slug, ProductParams params);

  Future<void> deleteProduct(String slug);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  const ProductsRemoteDataSourceImpl(this._api);

  static const int _visibleValue = 1;
  static const int _hiddenValue = 0;

  final ApiConsumer _api;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _api.get(EndPoints.adminProducts);
    return ResponseReader.list(response).map(ProductModel.fromJson).toList();
  }

  @override
  Future<ProductModel> getProduct(String slug) async {
    final response = await _api.get(EndPoints.adminProductDetails(slug));
    return ProductModel.fromJson(ResponseReader.object(response));
  }

  @override
  Future<ProductModel> createProduct(ProductParams params) async {
    final form = await _buildForm(params);
    final response = await _api.post(EndPoints.adminProductStore, data: form);
    return ProductModel.fromJson(ResponseReader.object(response));
  }

  @override
  Future<ProductModel> updateProduct(String slug, ProductParams params) async {
    final form = await _buildForm(params);
    // DioConsumer sends a FormData put as POST + _method=PUT.
    final response = await _api.put(
      EndPoints.adminProductUpdate(slug),
      data: form,
    );
    return ProductModel.fromJson(ResponseReader.object(response));
  }

  @override
  Future<void> deleteProduct(String slug) async {
    await _api.delete(EndPoints.adminProductDelete(slug));
  }

  Future<FormData> _buildForm(ProductParams params) async {
    final image = await multipartFileOrNull(params.imagePath);

    return FormData.fromMap({
      'name': params.name,
      'price': params.price,
      'quantity': params.quantity,
      'category_id': params.categoryId,
      'visible': params.isVisible ? _visibleValue : _hiddenValue,
      // Always sent: an empty value is saved as null, so the edit form can
      // clear a description. A missing key has unknown behavior.
      'description': params.description ?? '',
      'image': ?image,
    });
  }
}
