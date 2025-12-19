class Listing {
  final String id;
  final String title;
  final String description;
  final int price;
  final String category;
  final String location;
  final List<String> images;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.location,
    required this.images,
    required this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
      location: json['location'] as String,
      images: List<String>.from(json['images'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'location': location,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

