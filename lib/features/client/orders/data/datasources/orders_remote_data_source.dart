import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/client/orders/data/models/order_model.dart';
import 'package:easy_shop/features/client/orders/data/models/place_order_request_model.dart';
import 'package:easy_shop/features/client/orders/domain/params/place_order_params.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> getOrder(String code);

  Future<OrderModel> placeOrder(PlaceOrderParams params);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._api);

  final ApiConsumer _api;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _api.get(EndPoints.clientOrders);
    return ResponseReader.list(response).map(OrderModel.fromJson).toList();
  }

  @override
  Future<OrderModel> getOrder(String code) async {
    final response = await _api.get(EndPoints.clientOrderDetails(code));
    return OrderModel.fromJson(ResponseReader.object(response));
  }

  @override
  Future<OrderModel> placeOrder(PlaceOrderParams params) async {
    final response = await _api.post(
      EndPoints.clientOrderStore,
      data: PlaceOrderRequestModel(params).toJson(),
    );
    return OrderModel.fromJson(ResponseReader.object(response));
  }
}
