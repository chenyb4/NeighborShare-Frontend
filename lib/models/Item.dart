class Item {
  String name;
  String ownerEmail;
  String description;

  Item({required this.name, required this.ownerEmail, this.description = ""});


  factory Item.fromJson(Map<String, dynamic> json) {
    return switch(json){
      {
      'name': String name,
      'ownerEmail':String ownerEmail,
      'description': String description,
      } =>
          Item(
            name: name,
            ownerEmail: ownerEmail,
            description: description,
          ),
      _ => throw const FormatException('Failed to load item.'),
    };
  }
}
