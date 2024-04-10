import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Item.dart';
import 'item_details.dart';
import 'my_items.dart';
import 'package:aad_hybrid/configs/colors.dart';
import 'package:aad_hybrid/configs/backend_address.dart';

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
    try {
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
    } catch (error) {
      print('Error fetching apartment name: $error');
      return 'Unknown Apartment';
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
      appBar: AppBar(
        title: const Text(
            "NeighborShare",
            style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeColor,
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
            ListTile(
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: addressBarBackgroundColor,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: FutureBuilder<String>(
                future: _fetchApartmentName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: addressBarTextColor,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          '${snapshot.data}',
                          style: TextStyle(
                            color: addressBarTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
            Expanded(
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
                          Uint8List? imageBytes = item.imageData != null
                              ? Uint8List.fromList(item.imageData!)
                              : null;
                          return Column(
                            children: [
                              ListTile(
                                leading: imageBytes != null
                                    ? Image.memory(
                                  imageBytes,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                    : SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Placeholder(),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetails(item: item),
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
                                      item.isAvailable ? "Available" : "Unavailable",
                                      style: TextStyle(
                                        color: item.isAvailable ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                tileColor: listTileBackgroundColor,
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
