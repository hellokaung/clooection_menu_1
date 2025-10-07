class CartItem {
  final String id;
  final String thumbnail;
  final String title;
  final List<Map<String, dynamic>> addOns;
  final String note;
  final int totalPrice;
  final int times;

  CartItem({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.addOns,
    required this.note,
    required this.totalPrice,
    required this.times,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'thumbnail': thumbnail,
    'title': title,
    'addOns': addOns,
    'note': note,
    'totalPrice': totalPrice,
    'times': times,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as String,
    thumbnail: json['thumbnail'] as String,
    title: json['title'] as String,
    addOns: (json['addOns'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList(),
    note: json['note'] as String,
    totalPrice: json['totalPrice'] as int,
    times: json['times'] as int,
  );
}
