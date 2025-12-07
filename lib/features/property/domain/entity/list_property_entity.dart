class ListPropertyEntity {
  final List<PropertyEntity> properties;
  final MetaEntity meta;

  const ListPropertyEntity({required this.properties, required this.meta});
}

class MetaEntity {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasMore;

  const MetaEntity({
    required this.total,
    required this.limit,
    required this.nextCursor,
    required this.hasMore,
  });
}

class PropertyEntity {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final int propertyTypeId;
  final List<String> amenities;
  final String address;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final int listingTypeId;
  final String price;
  final String currency;
  final bool isVerified;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<PropertyImageEntity> images;
  final PropertyTypeEntity? propertyType;
  final ListingTypeEntity? listingType;
  final List<PropertyAttributeEntity> attributes;
  final List<AllowedBillingPeriodEntity> allowedBillingPeriods;

  const PropertyEntity({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.propertyTypeId,
    required this.amenities,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.listingTypeId,
    required this.price,
    required this.currency,
    required this.isVerified,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.images,
    required this.propertyType,
    required this.listingType,
    required this.attributes,
    required this.allowedBillingPeriods,
  });
}

class PropertyImageEntity {
  final String url;
  final bool isPrimary;

  const PropertyImageEntity({required this.url, required this.isPrimary});
}

class PropertyTypeEntity {
  final int id;
  final String slug;
  final String label;

  const PropertyTypeEntity({
    required this.id,
    required this.slug,
    required this.label,
  });
}

class ListingTypeEntity {
  final int id;
  final String slug;
  final String label;

  const ListingTypeEntity({
    required this.id,
    required this.slug,
    required this.label,
  });
}

class PropertyAttributeEntity {
  final String id;
  final String propertyId;
  final int attributeTypeId;
  final String value;
  final AttributeTypeEntity? attributeType;

  const PropertyAttributeEntity({
    required this.id,
    required this.propertyId,
    required this.attributeTypeId,
    required this.value,
    required this.attributeType,
  });
}

class AttributeTypeEntity {
  final int id;
  final String slug;
  final String label;
  final String dataType;
  final String iconUrl;

  const AttributeTypeEntity({
    required this.id,
    required this.slug,
    required this.label,
    required this.dataType,
    required this.iconUrl,
  });
}

class AllowedBillingPeriodEntity {
  final String propertyId;
  final int billingPeriodId;
  final PropertyBillingPeriodEntity billingPeriod;

  const AllowedBillingPeriodEntity({
    required this.propertyId,
    required this.billingPeriodId,
    required this.billingPeriod,
  });
}

class PropertyBillingPeriodEntity {
  final int id;
  final String slug;
  final String label;
  final int durationMonths;

  const PropertyBillingPeriodEntity({
    required this.id,
    required this.slug,
    required this.label,
    required this.durationMonths,
  });
}
