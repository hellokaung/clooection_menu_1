import 'dart:convert';
import 'package:collection_menu_1/models/raw_data.dart';
import 'package:dio/dio.dart';

class ApiService {
  Dio dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  Future<RawData?> getRawData() async {
    try {
      var response = await dio.get('https://www.jsonkeeper.com/b/DSQ3K');
      // Ensure response.data is a Map, then convert to RawData
      if (response.data is Map<String, dynamic>) {
        return RawData.fromJson(response.data);
      } else if (response.data is String) {
        // If response is a JSON string, decode it first
        return RawData.fromJson(json.decode(response.data));
      } else {
        return null;
      }
    } on DioException catch (e) {
      print(e.message);
      return null;
    }
  }
}
