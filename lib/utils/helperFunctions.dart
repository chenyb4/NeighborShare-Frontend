import 'dart:convert';
import 'package:aad_hybrid/configs/backend_address.dart';
import '../models/Item.dart';
import 'package:http/http.dart' as http;

Future<List<Item>> fetchItems() async {
  final response = await http.get(Uri.parse(baseUrl+'/items'));
  if (response.statusCode == 200) {
    Iterable jsonResponse = jsonDecode(response.body);
    List<Item> items = jsonResponse.map((item) => Item.fromJson(item)).toList();
    return items;
  } else {
    throw Exception('Failed to load items');
  }
}




