import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final description = json['description']?.toString().trim();
    return CategoryModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      // The API saves an empty description as null
      description: (description == null || description.isEmpty)
          ? null
          : description,
    );
  }
}
