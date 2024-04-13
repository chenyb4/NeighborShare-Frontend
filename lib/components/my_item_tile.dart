import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../configs/colors.dart';
import '../models/Item.dart';
import '../screens/item_details.dart';

class MyItemTile extends StatelessWidget {
  final Item item;
  final Function(Item) onToggleAvailability;
  final Function(String) onDeleteItem;
  final Function(Item) onEditItem;

  MyItemTile({
    required this.item,
    required this.onToggleAvailability,
    required this.onDeleteItem,
    required this.onEditItem,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes = item.imageData != null ? Uint8List.fromList(item.imageData!) : null;

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
                  color: item.isAvailable ? Colors.green : Colors.red,
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
                  onToggleAvailability(item);
                },
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  onEditItem(item);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Deletion'),
                      content: Text('Are you sure you want to delete ${item.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            onDeleteItem(item.id);
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
  }
}
