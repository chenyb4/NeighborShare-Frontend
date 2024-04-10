import 'dart:convert';
import 'dart:typed_data';
import 'package:aad_hybrid/configs/backend_address.dart';
import 'package:aad_hybrid/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Item.dart';
import 'edit_item.dart';
import 'item_details.dart';

class MyItems extends StatefulWidget {
  @override
  _MyItemsState createState() => _MyItemsState();
}

class _MyItemsState extends State<MyItems> {
  late Future<List<Item>> futureItems = Future.value([]);
  late String myEmail;
  late String token;

  @override
  void initState() {
    super.initState();
    fetchTokenAndItems();
  }

  Future<void> fetchTokenAndItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    myEmail = getEmailFromToken(token);
    futureItems = fetchItems();
    setState(() {});
  }

  String getEmailFromToken(String token) {
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    String payload = parts[1];
    String decodedPayload = utf8.decode(base64Url.decode(payload));
    Map<String, dynamic> decodedPayloadMap = json.decode(decodedPayload);
    return decodedPayloadMap['email'];
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(
      Uri.parse(baseUrl + '/items'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable jsonResponse = jsonDecode(response.body);
      List<Item> items = jsonResponse.map((item) => Item.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.delete(
      Uri.parse(baseUrl + '/items/$itemId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchItems();
      });
    } else {
      throw Exception('Failed to delete item');
    }
  }

  Future<void> _toggleItemAvailability(Item item) async {
    if (token == null) {
      throw Exception('Token not found');
    }

    Map<String, dynamic> updatedFields = {
      'isAvailable': !item.isAvailable,
    };

    final response = await http.patch(
      Uri.parse(baseUrl + '/items/${item.id}'),
      body: jsonEncode(updatedFields),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchItems();
      });
    } else {
      throw Exception('Failed to toggle item availability');
    }
  }


  Future<void> _refreshItems() async {
    setState(() {
      futureItems = fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Items"),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: Center(
          child: FutureBuilder<List<Item>>(
            future: futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Item> myItems = snapshot.data!
                    .where((item) => item.ownerEmail == myEmail)
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetails(item: item),
                              ),
                            );
                          },
                          title: Text(
                              item.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.description),
                              Row(
                                children: [
                                  Icon(Icons.location_on),
                                  Text(item.apartmentNumber),
                                ],
                              ),
                              Text(
                                item.isAvailable ? "Available" : "Unavailable",
                                style: TextStyle(
                                  color: item.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                          tileColor: listTileBackgroundColor,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.isAvailable,
                                onChanged: (value) {
                                  _toggleItemAvailability(item);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditItem(item: item),
                                    ),
                                  ).then((value) {
                                    setState(() {
                                      futureItems = fetchItems();
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete ${item.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteItem(item.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
        backgroundColor: themeColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
