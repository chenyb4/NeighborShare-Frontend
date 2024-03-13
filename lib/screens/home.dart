import 'dart:convert';
import 'package:aad_hybrid/data/data.dart';
import 'package:aad_hybrid/models/Item.dart';
import 'package:aad_hybrid/utils/backend_address.dart';
import 'package:aad_hybrid/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/helperFunctions.dart';
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
    myEmail = myDummyEmail; // Assign your email address from the data.dart file
    futureItems = fetchItems();
  }

  Future<void> _deleteItem(String itemId) async {
    final response = await http.delete(Uri.parse(baseUrl+'/items/$itemId'));
    if (response.statusCode == 200) {
      // Item deleted successfully, refresh the list
      setState(() {
        futureItems = fetchItems(); // Refresh the list of items
      });
    } else {
      // Failed to delete item
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item'),
          backgroundColor: Colors.red,
        ),
      );
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
                  String availabilityText = snapshot.data![index].isAvailable ? "Available" : "Unavailable";
                  Color availabilityColor = snapshot.data![index].isAvailable ? Colors.green : Colors.red;

                  // Check if the ownerEmail of the item matches your email
                  bool isMyItem = snapshot.data![index].ownerEmail == myEmail;

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
                            Text(snapshot.data![index].id),
                            Row(
                              children: [
                                Icon(Icons.location_on),
                                Text(snapshot.data![index].apartmentNumber),
                              ],
                            ),
                            Text(
                              availabilityText,
                              style: TextStyle(
                                color: availabilityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        tileColor: themeColorShade2,
                        trailing: isMyItem
                            ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteItem(snapshot.data![index].id); // Pass item ID to delete function
                          },
                        )
                            : null, // If it's not your item, don't show the delete icon
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
          Navigator.pushNamed(context, '/addItem')
              .then((value) {
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
