import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:aad_hybrid/configs/colors.dart';
import '../models/Item.dart';
import '../screens/item_details.dart';


class ItemList extends StatelessWidget {
  final Future<List<Item>> itemFuture;
  final String myEmail;

  ItemList({required this.itemFuture, required this.myEmail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: itemFuture,
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
    );
  }
}
