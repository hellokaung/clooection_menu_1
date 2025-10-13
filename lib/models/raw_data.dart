import 'dart:convert';

RawData rawDataFromJson(String str) => RawData.fromJson(json.decode(str));

String rawDataToJson(RawData data) => json.encode(data.toJson());

class RawData {
  Info info;
  Special special;
  List<Slide> slide;
  List<AdBanner> adBanner;
  List<Category> categories;
  List<ListElement> lists;
  List<AddOn> addOn;

  RawData({
    required this.info,
    required this.special,
    required this.slide,
    required this.adBanner,
    required this.categories,
    required this.lists,
    required this.addOn,
  });

  factory RawData.fromJson(Map<String, dynamic> json) => RawData(
    info: Info.fromJson(json["info"] ?? {}),
    special: Special.fromJson(json["special"] ?? {}),
    slide: json["slide"] != null
        ? List<Slide>.from(json["slide"].map((x) => Slide.fromJson(x)))
        : [],
    adBanner: json["ad_banner"] != null
        ? List<AdBanner>.from(
            json["ad_banner"].map((x) => AdBanner.fromJson(x)),
          )
        : [],
    categories: json["categories"] != null
        ? List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x)),
          )
        : [],
    lists: json["lists"] != null
        ? List<ListElement>.from(
            json["lists"].map((x) => ListElement.fromJson(x)),
          )
        : [],
    addOn: json["add_on"] != null
        ? List<AddOn>.from(json["add_on"].map((x) => AddOn.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "info": info.toJson(),
    "special": special.toJson(),
    "slide": List<dynamic>.from(slide.map((x) => x.toJson())),
    "ad_banner": List<dynamic>.from(adBanner.map((x) => x.toJson())),
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "lists": List<dynamic>.from(lists.map((x) => x.toJson())),
    "add_on": List<dynamic>.from(addOn.map((x) => x.toJson())),
  };
}

class Info {
  String version;
  String releaseDate;
  String updateDate;
  String name;
  String logo;
  String nightLogo;
  String description;
  String mapLink;
  String phone;
  String googleLink;

  Info({
    required this.version,
    required this.releaseDate,
    required this.updateDate,
    required this.name,
    required this.logo,
    required this.nightLogo,
    required this.description,
    required this.mapLink,
    required this.phone,
    required this.googleLink,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    version: json["version"] ?? "",
    releaseDate: json["release_date"] ?? "",
    updateDate: json["update_date"] ?? "",
    name: json["name"] ?? "",
    logo: json["logo"] ?? "",
    nightLogo: json["night_logo"] ?? "",
    description: json["description"] ?? "",
    mapLink: json["map_link"] ?? "",
    phone: json["phone"] ?? "",
    googleLink: json["google_link"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "version": version,
    "release_date": releaseDate,
    "update_date": updateDate,
    "name": name,
    "logo": logo,
    "night_logo": nightLogo,
    "description": description,
    "map_link": mapLink,
    "phone": phone,
    "google_link": googleLink,
  };
}

class Special {
  String title;
  String id;
  String day;
  String end;

  Special({
    required this.title,
    required this.id,
    required this.day,
    required this.end,
  });

  factory Special.fromJson(Map<String, dynamic> json) => Special(
    title: json["title"] ?? "",
    id: json["id"] ?? "",
    day: json["day"] ?? "",
    end: json["end"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "id": id,
    "day": day,
    "end": end,
  };
}

class Slide {
  int id;
  String thumbnail;
  String title;
  String desc;
  String link;
  bool directGo;
  bool ad;
  bool showText;
  String day;
  String end;

  Slide({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.desc,
    required this.link,
    required this.directGo,
    required this.ad,
    required this.showText,
    required this.day,
    required this.end,
  });

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
    id: json["id"] ?? 0,
    thumbnail: json["thumbnail"] ?? "",
    title: json["title"] ?? "",
    desc: json["desc"] ?? "",
    link: json["link"] ?? "",
    directGo: json["direct_go"] ?? false,
    ad: json["ad"] ?? false,
    showText: json["show_text"] ?? false,
    day: json["day"] ?? "",
    end: json["end"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "thumbnail": thumbnail,
    "title": title,
    "desc": desc,
    "link": link,
    "direct_go": directGo,
    "ad": ad,
    "show_text": showText,
    "day": day,
    "end": end,
  };

  factory Slide.fromMap(Map<String, dynamic> map) => Slide(
    id: map['id'] as int? ?? 0,
    thumbnail: map['thumbnail'] as String? ?? "",
    title: map['title'] as String? ?? "",
    desc: map['desc'] as String? ?? "",
    link: map['link'] as String? ?? "",
    directGo: map['direct_go'] as bool? ?? false,
    ad: map['ad'] as bool? ?? false,
    showText: map['show_text'] as bool? ?? false,
    day: map['day'] as String? ?? "",
    end: map['end'] as String? ?? "",
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'thumbnail': thumbnail,
    'title': title,
    'desc': desc,
    'link': link,
    'direct_go': directGo,
    'ad': ad,
    'show_text': showText,
    'day': day,
    'end': end,
  };
}

class AdBanner {
  String id;
  String tag;
  String thumbnail;
  String title;
  String desc;
  String link;
  bool directGo;
  String day;
  String end;

  AdBanner({
    required this.id,
    required this.tag,
    required this.thumbnail,
    required this.title,
    required this.desc,
    required this.link,
    required this.directGo,
    required this.day,
    required this.end,
  });

  factory AdBanner.fromJson(Map<String, dynamic> json) => AdBanner(
    id: json["id"] ?? "",
    tag: json["tag"] ?? "",
    thumbnail: json["thumbnail"] ?? "",
    title: json["title"] ?? "",
    desc: json["desc"] ?? "",
    link: json["link"] ?? "",
    directGo: json["direct_go"] ?? false,
    day: json["day"] ?? "",
    end: json["end"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tag": tag,
    "thumbnail": thumbnail,
    "title": title,
    "desc": desc,
    "link": link,
    "direct_go": directGo,
    "day": day,
    "end": end,
  };

  factory AdBanner.fromMap(Map<String, dynamic> map) => AdBanner(
    id: map['id'] as String? ?? "",
    tag: map['tag'] as String? ?? "",
    thumbnail: map['thumbnail'] as String? ?? "",
    title: map['title'] as String? ?? "",
    desc: map['desc'] as String? ?? "",
    link: map['link'] as String? ?? "",
    directGo: map['direct_go'] as bool? ?? false,
    day: map['day'] as String? ?? "",
    end: map['end'] as String? ?? "",
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tag': tag,
    'thumbnail': thumbnail,
    'title': title,
    'desc': desc,
    'link': link,
    'direct_go': directGo,
    'day': day,
    'end': end,
  };
}

class AddOn {
  String name;
  String type;
  int price;

  AddOn({required this.name, required this.type, required this.price});

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    name: json["name"] ?? "",
    type: json["type"] ?? "",
    price: json["price"] ?? 0,
  );

  Map<String, dynamic> toJson() => {"name": name, "type": type, "price": price};

  factory AddOn.fromMap(Map<String, dynamic> map) => AddOn(
    name: map['name'] as String? ?? "",
    type: map['type'] as String? ?? "",
    price: map['price'] as int? ?? 0,
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
    name: json["name"] ?? "",
    id: json["id"] ?? "",
    food: json["food"] ?? false,
    openIn: json["open_in"] ?? "",
    iconId: json["icon_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
    "food": food,
    "open_in": openIn,
    "icon_id": iconId,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    name: map['name'] as String? ?? "",
    id: map['id'] as String? ?? "",
    food: map['food'] as bool? ?? false,
    openIn: map['open_in'] as String? ?? "",
    iconId: map['icon_id'] as String? ?? "",
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'id': id,
    'food': food,
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
    thumbnail: json["thumbnail"] ?? "",
    photos: json["photos"] != null
        ? List<String>.from(json["photos"].map((x) => x))
        : [],
    title: json["title"] ?? "",
    description: json["description"] != null
        ? List<String>.from(json["description"].map((x) => x))
        : [],
    ingredients: json["ingredients"] != null
        ? List<String>.from(json["ingredients"].map((x) => x))
        : [],
    price: json["price"] ?? 0,
    food: json["food"] ?? false,
    category: json["category"] ?? "",
    types: json["types"] ?? "",
    addOn: json["add_on"] ?? "",
    id: json["id"] ?? "",
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
    thumbnail: map['thumbnail'] as String? ?? "",
    photos: map['photos'] != null
        ? (jsonDecode(map['photos'] as String) as List<dynamic>).cast<String>()
        : [],
    title: map['title'] as String? ?? "",
    description: map['description'] != null
        ? (jsonDecode(map['description'] as String) as List<dynamic>)
              .cast<String>()
        : [],
    ingredients: map['ingredients'] != null
        ? (jsonDecode(map['ingredients'] as String) as List<dynamic>)
              .cast<String>()
        : [],
    price: map['price'] as int? ?? 0,
    food: map['food'] as bool? ?? false,
    category: map['category'] as String? ?? "",
    types: map['types'] as String? ?? "",
    addOn: map['add_on'] as String? ?? "",
    id: map['id'] as String? ?? "",
  );

  Map<String, dynamic> toMap() => {
    'thumbnail': thumbnail,
    'photos': jsonEncode(photos),
    'title': title,
    'description': jsonEncode(description),
    'ingredients': jsonEncode(ingredients),
    'price': price,
    'food': food,
    'category': category,
    'types': types,
    'add_on': addOn,
    'id': id,
  };
}
