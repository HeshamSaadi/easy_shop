import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<CategoryEntity>> call() async {
    final categories = await _repository.getCategories();
    final sorted = [...categories]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }
}
