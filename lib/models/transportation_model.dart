class Transportation {
  final int id;
  final int destinationId;
  final int transportTypeId;
  final int price;
  final String estimate;

  Transportation({
    required this.id,
    required this.destinationId,
    required this.transportTypeId,
    required this.price,
    required this.estimate,
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    return Transportation(
      id: json['id'] ?? 0,
      destinationId: json['destination_id'] ?? 0,
      transportTypeId: json['transport_type_id'] ?? 0,
      price: json['price'] ?? 0,
      estimate: json['estimate'] ?? '',
    );
  }
}

