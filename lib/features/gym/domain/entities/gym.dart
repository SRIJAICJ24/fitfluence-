import 'package:equatable/equatable.dart';

class Gym extends Equatable {
  final String id;
  final String name;
  final String city;
  final String? state;
  final String country;
  final double latitude;
  final double longitude;
  final String? address;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final List<String> facilities;
  final bool isVerified;

  const Gym({
    required this.id,
    required this.name,
    required this.city,
    this.state,
    this.country = 'India',
    required this.latitude,
    required this.longitude,
    this.address,
    this.rating = 0,
    this.reviewCount = 0,
    this.amenities = const [],
    this.facilities = const [],
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        state,
        country,
        latitude,
        longitude,
        address,
        rating,
        reviewCount,
        amenities,
        facilities,
        isVerified,
      ];
}
