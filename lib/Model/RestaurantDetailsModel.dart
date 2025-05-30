class Restaurant {
  final String name;
  final String? description;
  final Location location;
  final String contactNumber;
  final OpeningHours openingHours;
  final Images images;
  final Ratings ratings;

  Restaurant({
    required this.name,
    this.description,
    required this.location,
    required this.contactNumber,
    required this.openingHours,
    required this.images,
    required this.ratings,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : Location.empty(),
      contactNumber: json['contactNumber'] ?? '',
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromJson(json['openingHours'])
          : OpeningHours.empty(),
      images: json['images'] != null
          ? Images.fromJson(json['images'])
          : Images.empty(),
      ratings: json['ratings'] != null
          ? Ratings.fromJson(json['ratings'])
          : Ratings.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'location': location.toJson(),
      'contactNumber': contactNumber,
      'openingHours': openingHours.toJson(),
      'images': images.toJson(),
      'ratings': ratings.toJson(),
    };
  }
}

class Location {
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final String type;
  final List<double> coordinates;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? '',
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(
          (json['coordinates'] as List).map((x) => (x ?? 0.0).toDouble()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zipcode': zipcode,
      'type': type,
      'coordinates': coordinates,
    };
  }

  factory Location.empty() {
    return Location(
      address: '',
      city: '',
      state: '',
      country: '',
      zipcode: '',
      type: 'Point',
      coordinates: [],
    );
  }
}

class OpeningHours {
  final String open;
  final String close;

  OpeningHours({required this.open, required this.close});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      open: json['open'] ?? '',
      close: json['close'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
    };
  }

  factory OpeningHours.empty() {
    return OpeningHours(open: '', close: '');
  }
}

class Images {
  final List<String> hotelImages;
  final List<String> menuImages;
  final List<String> hotelMainImage;

  Images({
    required this.hotelImages,
    required this.menuImages,
    required this.hotelMainImage,
  });

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      hotelImages: json['hotelImages'] != null
          ? List<String>.from(json['hotelImages'])
          : [],
      menuImages: json['menuImages'] != null
          ? List<String>.from(json['menuImages'])
          : [],
      hotelMainImage: json['hotelMainImage'] != null
          ? List<String>.from(json['hotelMainImage'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelImages': hotelImages,
      'menuImages': menuImages,
      'hotelMainImage': hotelMainImage,
    };
  }

  factory Images.empty() {
    return Images(hotelImages: [], menuImages: [], hotelMainImage: []);
  }
}

class Ratings {
  final double averageRating;
  final int totalRatings;

  Ratings({required this.averageRating, required this.totalRatings});

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }

  factory Ratings.empty() {
    return Ratings(averageRating: 0.0, totalRatings: 0);
  }
}
