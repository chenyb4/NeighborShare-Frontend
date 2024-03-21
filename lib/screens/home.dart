import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';
import '../models/Item.dart';
import 'item_details.dart';
import 'my_items.dart';
import 'package:aad_hybrid/configs/colors.dart';
import 'package:aad_hybrid/screens/add_item.dart';
import 'package:aad_hybrid/configs/backend_address.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Item>> futureItems = Future.value([]);
  late String myEmail = ''; // Initialize with empty string
  late String token;

  @override
  void initState() {
    super.initState();
    fetchTokenAndItems();
  }

  Future<void> fetchTokenAndItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    Map<String, dynamic> payload = _parseJwt(token); // Parse JWT token payload
    myEmail = payload['email'] ?? ''; // Extract email from payload
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NeighborShare"),
        centerTitle: true,
        backgroundColor: themeColorShade1,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeColorShade1,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('My Items'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyItems(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () {
            setState(() {
              futureItems = fetchItems();
            });
            return futureItems;
          },
          child: FutureBuilder<List<Item>>(
            future: futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Item> myItems = snapshot.data!
                    .where((item) => item.ownerEmail != myEmail)
                    .toList();
                return ListView.builder(
                  itemCount: myItems.length,
                  itemBuilder: (context, index) {
                    Item item = myItems[index];
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ItemDetails(item: item),
                              ),
                            );
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on),
                                  Text(item.apartmentNumber),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.description),
                              Text(
                                item.isAvailable
                                    ? "Available"
                                    : "Unavailable",
                                style: TextStyle(
                                  color: item.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          tileColor: themeColorShade2,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.white,
                        ),
                      ],
                    );
                  },
                );
              } else {
                return Text('No data available');
              }
            },
          ),
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
        backgroundColor: themeColorShade1,
        child: Icon(Icons.add),
      ),
    );
  }
}
