class Item {
  String id;
  String name;
  String ownerEmail;
  String description;
  String apartmentNumber;
  bool isAvailable;
  List<int>? imageData;

  Item({
    required this.id,
    required this.name,
    required this.ownerEmail,
    this.description = "",
    required this.apartmentNumber,
    required this.isAvailable,
    this.imageData,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    List<int>? imageData = (json['imageData'] != null)
        ? List<int>.from(json['imageData']['data'])
        : null;

    return Item(
      id: json['_id'],
      name: json['name'],
      ownerEmail: json['ownerEmail'],
      description: json['description'] ?? "",
      apartmentNumber: json['apartmentNumber'],
      isAvailable: json['isAvailable'] ?? false,
      imageData: imageData,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? imageDataJson;
    if (imageData != null) {
      imageDataJson = {'type': 'Buffer', 'data': imageData};
    }

    return {
      '_id': id,
      'name': name,
      'ownerEmail': ownerEmail,
      'description': description,
      'apartmentNumber': apartmentNumber,
      'isAvailable': isAvailable,
      'imageData': imageDataJson,
    };
  }

  Item copyWith({
    String? id,
    String? name,
    String? ownerEmail,
    String? description,
    String? apartmentNumber,
    bool? isAvailable,
    List<int>? imageData,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      description: description ?? this.description,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      imageData: imageData ?? this.imageData,
    );
  }
}
