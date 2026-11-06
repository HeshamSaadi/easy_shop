class OrderProductEntity {
  const OrderProductEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.categoryName,
  });

  final int id;
  final String name;
  final String imageUrl;
  final String? categoryName;
}
