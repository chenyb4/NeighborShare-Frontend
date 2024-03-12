import 'dart:convert';
import 'package:aad_hybrid/models/Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'item_details.dart';

Future<List<Item>> fetchItems() async {
  final response = await http.get(Uri.parse('http://localhost:3000/items'));
  if (response.statusCode == 200) {
    Iterable jsonResponse = jsonDecode(response.body);
    List<Item> items = jsonResponse.map((item) => Item.fromJson(item)).toList();
    return items;
  } else {
    throw Exception('Failed to load items');
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState()=>_HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Item>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = fetchItems();
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
              return CircularProgressIndicator(); // While data is loading
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Data loaded successfully, display the list
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  // Determine text and color based on isAvailable
                  String availabilityText = snapshot.data![index].isAvailable ? "Available" : "Unavailable";
                  Color availabilityColor = snapshot.data![index].isAvailable ? Colors.green : Colors.red;

                  return Column(
                    children: [
                      ListTile(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetails(item: snapshot.data![index]),
                            ),
                          );
                        },
                        title: Text(snapshot.data![index].name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data![index].description),
                            Text(
                              availabilityText,
                              style: TextStyle(
                                color: availabilityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        tileColor: Colors.amberAccent,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on),
                            Text(snapshot.data![index].apartmentNumber),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white,
                      )
                    ],
                  );
                },
              );
            } else {
              return Text('No data available'); // If no data is available
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addItem');
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }
}
