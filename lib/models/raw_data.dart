import 'dart:convert';

RawData rawDataFromJson(String str) => RawData.fromJson(json.decode(str));

String rawDataToJson(RawData data) => json.encode(data.toJson());

class RawData {
  List<Category> categories;
  List<ListElement> lists;
  List<AddOn> addOn;

  RawData({required this.categories, required this.lists, required this.addOn});

  factory RawData.fromJson(Map<String, dynamic> json) => RawData(
    categories: List<Category>.from(
      json["categories"].map((x) => Category.fromJson(x)),
    ),
    lists: List<ListElement>.from(
      json["lists"].map((x) => ListElement.fromJson(x)),
    ),
    addOn: List<AddOn>.from(json["add_on"].map((x) => AddOn.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
    "add_on": List<dynamic>.from(addOn.map((x) => x.toJson())),
  };
}

class AddOn {
  String name;
  String type;
  int price;

  AddOn({required this.name, required this.type, required this.price});

  factory AddOn.fromJson(Map<String, dynamic> json) =>
      AddOn(name: json["name"], type: json["type"], price: json["price"]);

  Map<String, dynamic> toJson() => {"name": name, "type": type, "price": price};

  factory AddOn.fromMap(Map<String, dynamic> map) => AddOn(
    name: map['name'] as String,
    type: map['type'] as String,
    price: map['price'] as int,
  );

  Map<String, dynamic> toMap() => {'name': name, 'type': type, 'price': price};
}

class Category {
  String name;
  String id;
  bool food;
  String openIn;
  String iconId;

  Category({
    required this.name,
    required this.id,
    required this.food,
    required this.openIn,
    required this.iconId,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    name: json["name"],
    id: json["id"],
    food: json["food"],
    openIn: json["open_in"],
    iconId: json["icon_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
    "food": food,
    "open_in": openIn,
    "icon_id": iconId,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    name: map['name'] as String,
    id: map['id'] as String,
    food: (map['food'] as int) == 1,
    openIn: map['open_in'] as String,
    iconId: map['icon_id'] as String,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'id': id,
    'food': food ? 1 : 0,
    'open_in': openIn,
    'icon_id': iconId,
  };
}

class ListElement {
  String thumbnail;
  List<String> photos;
  String title;
  List<String> description;
  List<String> ingredients;
  int price;
  bool food;
  String category;
  String types;
  String addOn;
  String id;

  ListElement({
    required this.thumbnail,
    required this.photos,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.price,
    required this.food,
    required this.category,
    required this.types,
    required this.addOn,
    required this.id,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    thumbnail: json["thumbnail"],
    photos: List<String>.from(json["photos"].map((x) => x)),
    title: json["title"],
    description: List<String>.from(json["description"].map((x) => x)),
    ingredients: List<String>.from(json["ingredients"].map((x) => x)),
    price: json["price"],
    food: json["food"],
    category: json["category"],
    types: json["types"],
    addOn: json["add_on"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "thumbnail": thumbnail,
    "photos": List<dynamic>.from(photos.map((x) => x)),
    "title": title,
    "description": List<dynamic>.from(description.map((x) => x)),
    "ingredients": List<dynamic>.from(ingredients.map((x) => x)),
    "price": price,
    "food": food,
    "category": category,
    "types": types,
    "add_on": addOn,
    "id": id,
  };

  factory ListElement.fromMap(Map<String, dynamic> map) => ListElement(
    thumbnail: map['thumbnail'] as String,
    photos: (jsonDecode(map['photos'] as String) as List<dynamic>)
        .cast<String>(),
    title: map['title'] as String,
    description: (jsonDecode(map['description'] as String) as List<dynamic>)
        .cast<String>(),
    ingredients: (jsonDecode(map['ingredients'] as String) as List<dynamic>)
        .cast<String>(),
    price: map['price'] as int,
    food: (map['food'] as int) == 1,
    category: map['category'] as String,
    types: map['types'] as String,
    addOn: map['add_on'] as String,
    id: map['id'] as String,
  );

  Map<String, dynamic> toMap() => {
    'thumbnail': thumbnail,
    'photos': jsonEncode(photos),
    'title': title,
    'description': jsonEncode(description),
    'ingredients': jsonEncode(ingredients),
    'price': price,
    'food': food ? 1 : 0,
    'category': category,
    'types': types,
    'add_on': addOn,
    'id': id,
  };
}
