import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:aad_hybrid/configs/backend_address.dart';
import 'package:aad_hybrid/models/Item.dart';
import 'package:aad_hybrid/components/app_bar.dart';
import 'package:aad_hybrid/components//drawer.dart';
import 'package:aad_hybrid/components/address_bar.dart';
import 'package:aad_hybrid/components/item_list.dart';
import '../configs/colors.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Item>> futureItems = Future.value([]);
  late String myEmail = '';
  late String token;

  @override
  void initState() {
    super.initState();
    fetchTokenAndItems();
  }

  Future<void> fetchTokenAndItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    Map<String, dynamic> payload = _parseJwt(token);
    myEmail = payload['email'] ?? '';
    futureItems = fetchItems();
    setState(() {});
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid JWT token');
    }
    final payload = parts[1];
    return jsonDecode(utf8.decode(base64Url.decode(payload)));
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(
      Uri.parse(baseUrl + '/items'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable jsonResponse = jsonDecode(response.body);
      List<Item> items =
      jsonResponse.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<String> _fetchApartmentName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    Map<String, dynamic> payload = _parseJwt(token);
    String userEmail = payload['email'] ?? '';

    final userResponse = await http.get(
      Uri.parse(baseUrl + '/users?email=$userEmail'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (userResponse.statusCode == 200) {
      List<dynamic> users = jsonDecode(userResponse.body);
      if (users.isNotEmpty) {
        dynamic apartmentId = users[0]['apartment_id'];
        final apartmentResponse = await http.get(
          Uri.parse(baseUrl + '/apartments/$apartmentId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (apartmentResponse.statusCode == 200) {
          Map<String, dynamic> apartmentData = jsonDecode(apartmentResponse.body);
          return apartmentData['name'] ?? 'Unknown Apartment';
        } else {
          throw Exception('Failed to load apartment');
        }
      } else {
        throw Exception('User not found');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(logoutCallback: _logout),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AddressBar(addressFuture: _fetchApartmentName()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  setState(() {
                    futureItems = fetchItems();
                  });
                  return futureItems;
                },
                child: ItemList(itemFuture: futureItems, myEmail: myEmail),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addItem').then((value) {
            setState(() {
              futureItems = fetchItems();
            });
          });
        },
        backgroundColor: themeColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
