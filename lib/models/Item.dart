class Item {
  String name;
  String ownerEmail;
  String description;
  String apartmentNumber;
  bool isAvailable;

  Item({required this.name, required this.ownerEmail, this.description = "", required this.apartmentNumber, required this.isAvailable});


  factory Item.fromJson(Map<String, dynamic> json) {
    return switch(json){
      {
      'name': String name,
      'ownerEmail':String ownerEmail,
      'description': String description,
      'apartmentNumber':String apartmentNumber,
      'isAvailable': bool isAvailable,
      } =>
          Item(
            name: name,
            ownerEmail: ownerEmail,
            description: description,
            apartmentNumber:apartmentNumber,
            isAvailable: isAvailable,
          ),
      _ => throw const FormatException('Failed to load item.'),
    };
  }
}
