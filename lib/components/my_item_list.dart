import 'package:flutter/material.dart';
import '../models/Item.dart';
import 'my_item_tile.dart';

class MyItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onToggleAvailability;
  final Function(String) onDeleteItem;
  final Function(Item) onEditItem;

  MyItemList({
    required this.items,
    required this.onToggleAvailability,
    required this.onDeleteItem,
    required this.onEditItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        Item item = items[index];
        return MyItemTile(
          item: item,
          onToggleAvailability: onToggleAvailability,
          onDeleteItem: onDeleteItem,
          onEditItem: onEditItem,
        );
      },
    );
  }
}
