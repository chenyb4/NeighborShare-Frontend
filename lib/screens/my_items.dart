import 'dart:convert';
import 'package:aad_hybrid/data/data.dart';
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
  late String myEmail; // Declare a variable to store your email address
  late String token;

  @override
  void initState() {
    super.initState();
    fetchTokenAndItems();
  }

  Future<void> fetchTokenAndItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    myEmail = "chenyb0417@outlook.com"; // Use email from SharedPreferences
    futureItems = fetchItems();
    setState(() {});
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(
      Uri.parse(baseUrl + '/items'),
      headers: {'Authorization': 'Bearer $token'}, // Include authorization header
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

  Future<void> _deleteItem(String itemId) async {
    final response =
    await http.delete(Uri.parse(baseUrl + '/items/$itemId'));
    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchItems(); // Refresh the list of items
      });
    } else {
      throw Exception('Failed to delete item');
    }
  }

  Future<void> _toggleItemAvailability(Item item) async {
    Item updatedItem = item.copyWith(isAvailable: !item.isAvailable);
    final response = await http.put(
      Uri.parse(baseUrl + '/items/${item.id}'),
      body: jsonEncode(updatedItem.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchItems(); // Refresh the list of items
      });
    } else {
      throw Exception('Failed to toggle item availability');
    }
  }

  Future<void> _refreshItems() async {
    setState(() {
      futureItems = fetchItems(); // Refresh the list of items
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Items"),
        centerTitle: true,
        backgroundColor: themeColorShade1,
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
                // Filter items based on owner email
                List<Item> myItems = snapshot.data!
                    .where((item) => item.ownerEmail == myEmail)
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
                          tileColor: themeColorShade2,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.isAvailable,
                                onChanged: (value) {
                                  // Toggle item availability
                                  _toggleItemAvailability(item);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Navigate to edit item screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditItem(item: item),
                                    ),
                                  ).then((value) {
                                    setState(() {
                                      // Update state or call a function to refresh the screen
                                      futureItems = fetchItems();
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Show confirmation dialog before deleting the item
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete ${item.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Delete the item and close the dialog
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
              // Update state or call a function to refresh the screen
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
