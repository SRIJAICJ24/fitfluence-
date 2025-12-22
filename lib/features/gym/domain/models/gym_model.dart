import 'package:equatable/equatable.dart';

class GymModel extends Equatable {
  final String id;
  final String name;
  final String city;
  final String? state;
  final String? country;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> amenities;
  final List<String> facilities;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;
  final String? operatingHoursOpen; // 'HH:MM:SS'
  final String? operatingHoursClose; // 'HH:MM:SS'

  const GymModel({
    required this.id,
    required this.name,
    required this.city,
    this.state,
    this.country,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.amenities = const [],
    this.facilities = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isActive = true,
    this.operatingHoursOpen,
    this.operatingHoursClose,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      amenities: List<String>.from(json['amenities'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      operatingHoursOpen: json['operating_hours_open'] as String?,
      operatingHoursClose: json['operating_hours_close'] as String?,
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
      'phone': phone,
      'email': email,
      'website': website,
      'amenities': amenities,
      'facilities': facilities,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_active': isActive,
      'operating_hours_open': operatingHoursOpen,
      'operating_hours_close': operatingHoursClose,
    };
  }

  @override
  List<Object?> get props => [
        id, name, city, state, country, latitude, longitude, address, 
        phone, email, website, amenities, facilities, rating, reviewCount, 
        isVerified, isActive, operatingHoursOpen, operatingHoursClose
      ];
}
