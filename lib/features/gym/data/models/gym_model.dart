import '../../domain/entities/gym.dart';

class GymModel extends Gym {
  const GymModel({
    required super.id,
    required super.name,
    required super.city,
    super.state,
    super.country,
    required super.latitude,
    required super.longitude,
    super.address,
    super.rating,
    super.reviewCount,
    super.amenities,
    super.facilities,
    super.isVerified,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'India',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'rating': rating,
      'review_count': reviewCount,
      'amenities': amenities,
      'facilities': facilities,
      'is_verified': isVerified,
    };
  }
}
