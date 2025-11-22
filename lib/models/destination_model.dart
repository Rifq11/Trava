class Destination {
  final int id;
  final int categoryId;
  final int createdBy;
  final String name;
  final String description;
  final String location;
  final int pricePerPerson;
  final String image;

  Destination({
    required this.id,
    required this.categoryId,
    required this.createdBy,
    required this.name,
    required this.description,
    required this.location,
    required this.pricePerPerson,
    required this.image,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      pricePerPerson: json['price_per_person'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'created_by': createdBy,
      'name': name,
      'description': description,
      'location': location,
      'price_per_person': pricePerPerson,
      'image': image,
    };
  }
}

class DestinationCategory {
  final int id;
  final String name;

  DestinationCategory({
    required this.id,
    required this.name,
  });

  factory DestinationCategory.fromJson(Map<String, dynamic> json) {
    return DestinationCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

