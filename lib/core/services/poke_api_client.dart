import 'package:dio/dio.dart';

final Dio pokeApiDio = Dio(
  BaseOptions(
    baseUrl: 'https://pokeapi.co/api/v2',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'User-Agent': 'PokePoke-App'},
  ),
);
