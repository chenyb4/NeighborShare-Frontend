class Item {
  String id; // Define a property to store the MongoDB _id
  String name;
  String ownerEmail;
  String description;
  String apartmentNumber;
  bool isAvailable;

  Item({required this.id, required this.name, required this.ownerEmail, this.description = "", required this.apartmentNumber, required this.isAvailable});

  // Factory method to create Item object from JSON data
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'], // Assign value of _id field to id property
      name: json['name'],
      ownerEmail: json['ownerEmail'],
      description: json['description'] ?? "", // Use null-aware operator to handle optional field
      apartmentNumber: json['apartmentNumber'],
      isAvailable: json['isAvailable'] ?? false, // Default value for boolean field
    );
  }

}
