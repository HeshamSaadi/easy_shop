import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/admin/orders/data/models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> getOrder(String code);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._api);

  final ApiConsumer _api;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _api.get(EndPoints.adminOrders);
    return ResponseReader.list(response).map(OrderModel.fromJson).toList();
  }

  @override
  Future<OrderModel> getOrder(String code) async {
    final response = await _api.get(EndPoints.adminOrderDetails(code));
    return OrderModel.fromJson(ResponseReader.object(response));
  }
}
