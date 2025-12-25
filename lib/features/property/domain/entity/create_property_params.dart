class CreatePropertyParams {
  final List<String> imageFilePaths;
  final String title;
  final String? description;
  final int propertyTypeId;
  final int listingTypeId;
  final String price;
  final String? currency;
  final String address;
  final String city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final List<int> billingPeriodIds;
  final List<String>? amenities;
  final List<Map<String, dynamic>>? attributes;

  CreatePropertyParams({
    required this.imageFilePaths,
    required this.title,
    this.description,
    required this.propertyTypeId,
    required this.listingTypeId,
    required this.price,
    this.currency,
    required this.address,
    required this.city,
    this.country,
    this.latitude,
    this.longitude,
    required this.billingPeriodIds,
    this.amenities,
    this.attributes,
  });
}
