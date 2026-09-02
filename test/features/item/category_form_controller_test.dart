import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softverse/core/models/response_data.dart';
import 'package:softverse/core/services/storage_service.dart';
import 'package:softverse/features/item/controller/category_controller.dart';
import 'package:softverse/features/item/data/category_repository.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await StorageService.saveUserSession(
      id: 'user-id',
      fullName: 'Owner',
      email: 'owner@example.com',
      accessToken: 'token',
      refreshToken: 'refresh',
      role: 'owner',
      businessId: 'business-id',
      permissions: const ['create_edit_categories'],
    );
  });

  tearDown(Get.reset);

  testWidgets('category save cannot submit twice', (tester) async {
    final repository = _DelayedCategoryRepository();
    final controller = CategoryFormController(repository: repository);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    controller.nameController.text = 'Food';

    final first = controller.save();
    final second = controller.save();

    expect(repository.createCalls, 1);
    expect(controller.isSaving.value, isTrue);
    repository.complete(
      ResponseData(
        isSuccess: false,
        statusCode: 409,
        errorMessage: 'Category already exists',
        responseData: null,
      ),
    );
    await Future.wait([first, second]);
    await tester.pump(const Duration(seconds: 4));

    expect(repository.createCalls, 1);
    expect(controller.isSaving.value, isFalse);
  });

  test('category payload includes the selected API color and shape', () {
    final controller = CategoryFormController(
      repository: _DelayedCategoryRepository(),
    );
    controller.nameController.text = 'Beverages';
    controller.descriptionController.text = 'Cold drinks';
    controller.selectColor(5);
    controller.selectShape(3);

    expect(controller.buildPayload(), {
      'name': 'Beverages',
      'description': 'Cold drinks',
      'colorIndex': 5,
      'shape': 'hexagon',
      'isActive': true,
    });
  });
}

class _DelayedCategoryRepository implements CategoryRepository {
  final _response = Completer<ResponseData>();
  int createCalls = 0;

  void complete(ResponseData response) => _response.complete(response);

  @override
  Future<ResponseData> createCategory(Map<String, dynamic> body) {
    createCalls++;
    return _response.future;
  }

  @override
  Future<ResponseData> deleteCategory(String id) => throw UnimplementedError();

  @override
  Future<ResponseData> fetchAdminCategories() => throw UnimplementedError();

  @override
  Future<ResponseData> fetchCategories() => throw UnimplementedError();

  @override
  Future<ResponseData> updateCategory(String id, Map<String, dynamic> body) =>
      throw UnimplementedError();
}
