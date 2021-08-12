import 'dart:convert';

import 'package:cuidapet_api/modules/categories/service/i_categories_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'categories_controller.g.dart';

@Injectable()
class CategoriesController {
  CategoriesController({required this.service});

  ICategoriesService service;

  @Route.get('/')
  Future<Response> find(Request request) async {
    try {
      final categories = await service.findAll();

      final categoriesResponse = categories
          .map((e) =>
              <String, dynamic>{'id': e.id, 'name': e.name, 'type': e.type})
          .toList();

      return Response.ok(jsonEncode(categoriesResponse));
    } on Exception {
      return Response.internalServerError();
    }
  }

  Router get router => _$CategoriesControllerRouter(this);
}
