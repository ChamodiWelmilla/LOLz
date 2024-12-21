import 'package:dio/dio.dart';

class JokeService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> fetchJokesRaw({
    required String category,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        'https://official-joke-api.appspot.com/jokes/$category/ten',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jokesJson = response.data;
        return jokesJson.take(limit).cast<Map<String, dynamic>>().toList();
      } else {
        throw Exception(
            'Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error fetching jokes: ${e.toString()}');
    }
  }
}
