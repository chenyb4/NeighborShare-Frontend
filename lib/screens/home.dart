import 'dart:convert';
import 'package:aad_hybrid/data/data.dart';
import 'package:aad_hybrid/utils/backend_address.dart';
import 'package:aad_hybrid/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/Item.dart';
import 'edit_item.dart';
import 'item_details.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Item>> futureItems;
  late String myEmail; // Declare a variable to store your email address

  @override
  void initState() {
    super.initState();
    myEmail = myDummyEmail; // Replace with your actual email
    futureItems = fetchItems();
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse(baseUrl + '/items'));
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
    final response = await http.delete(Uri.parse(baseUrl + '/items/$itemId'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NeighborShare"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: FutureBuilder<List<Item>>(
          future: futureItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Item item = snapshot.data![index];
                  bool isMyItem = item.ownerEmail == myEmail;

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
                        title: Text(item.name),
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
                        tileColor: Colors.amberAccent,
                        trailing: isMyItem
                            ? Row(
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
                                      _deleteItem(item.id);
                                    },
                                  ),
                                ],
                              )
                            : null,
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
