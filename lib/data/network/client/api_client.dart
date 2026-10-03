import 'package:dio/dio.dart';
import '../entity/hero_entity.dart';
class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<List<HeroEntity>> getHeroes({required int page, required int limit}) async {
    final response = await _dio.get('/heroes', queryParameters: {
      '_page': page,
      '_per_page': limit,
    });
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data.map((value) => HeroEntity.fromJson(value as Map<String, dynamic>)).toList();
  }

  Future<HeroEntity> getHeroById(int id) async {
    final response = await _dio.get('/heroes/$id');
    return HeroEntity.fromJson(response.data as Map<String, dynamic>);
  }
}
