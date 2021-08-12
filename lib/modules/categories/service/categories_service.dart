import 'package:injectable/injectable.dart';

import '../../../entities/category.dart';
import '../data/i_categories_repository.dart';
import 'i_categories_service.dart';

@LazySingleton(as: ICategoriesService)
class CategoriesService implements ICategoriesService {
  CategoriesService({required this.repository});

  ICategoriesRepository repository;

  @override
  Future<List<Category>> findAll() => repository.findAll();
}
