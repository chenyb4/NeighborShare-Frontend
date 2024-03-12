class Item {
  String name;
  String ownerEmail;
  String description;
  String apartmentNumber;

  Item({required this.name, required this.ownerEmail, this.description = "", required this.apartmentNumber});


  factory Item.fromJson(Map<String, dynamic> json) {
    return switch(json){
      {
      'name': String name,
      'ownerEmail':String ownerEmail,
      'description': String description,
      'apartmentNumber':String apartmentNumber,
      } =>
          Item(
            name: name,
            ownerEmail: ownerEmail,
            description: description,
            apartmentNumber:apartmentNumber,
          ),
      _ => throw const FormatException('Failed to load item.'),
    };
  }
}
