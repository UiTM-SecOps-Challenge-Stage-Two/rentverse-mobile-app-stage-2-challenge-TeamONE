import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';

class ListPropertyResponseModel {
  final List<PropertyModel> data;
  final MetaModel meta;

  ListPropertyResponseModel({required this.data, required this.meta});

  factory ListPropertyResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final meta = MetaModel.fromJson(
      json['meta'] as Map<String, dynamic>? ?? {},
    );
    return ListPropertyResponseModel(
      data: rawList
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: meta,
    );
  }

  ListPropertyEntity toEntity() {
    return ListPropertyEntity(
      properties: data.map((e) => e.toEntity()).toList(),
      meta: meta.toEntity(),
    );
  }
}

class MetaModel {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasMore;

  MetaModel({
    required this.total,
    required this.limit,
    required this.nextCursor,
    required this.hasMore,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      total: json['total'] is num ? (json['total'] as num).toInt() : 0,
      limit: json['limit'] is num ? (json['limit'] as num).toInt() : 0,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  MetaEntity toEntity() {
    return MetaEntity(
      total: total,
      limit: limit,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }
}

class PropertyModel {
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
  final List<PropertyImageModel> images;
  final PropertyTypeModel? propertyType;
  final ListingTypeModel? listingType;
  final List<PropertyAttributeModel> attributes;
  final List<AllowedBillingPeriodModel> allowedBillingPeriods;

  PropertyModel({
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

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final attrsJson = json['attributes'] as List<dynamic>? ?? [];
    final allowedBillingJson =
        json['allowedBillingPeriods'] as List<dynamic>? ?? [];
    return PropertyModel(
      id: json['id'] as String? ?? '',
      landlordId: json['landlordId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyTypeId: (json['propertyTypeId'] as num?)?.toInt() ?? 0,
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      listingTypeId: (json['listingTypeId'] as num?)?.toInt() ?? 0,
      price: json['price']?.toString() ?? '0',
      currency: json['currency'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String?),
      deletedAt: _parseDate(json['deletedAt'] as String?),
      images: imagesJson
          .map((e) => PropertyImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      propertyType: json['propertyType'] == null
          ? null
          : PropertyTypeModel.fromJson(
              json['propertyType'] as Map<String, dynamic>,
            ),
      listingType: json['listingType'] == null
          ? null
          : ListingTypeModel.fromJson(
              json['listingType'] as Map<String, dynamic>,
            ),
      attributes: attrsJson
          .map(
            (e) => PropertyAttributeModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      allowedBillingPeriods: allowedBillingJson
          .map(
            (e) =>
                AllowedBillingPeriodModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  PropertyEntity toEntity() {
    return PropertyEntity(
      id: id,
      landlordId: landlordId,
      title: title,
      description: description,
      propertyTypeId: propertyTypeId,
      amenities: amenities,
      address: address,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      listingTypeId: listingTypeId,
      price: price,
      currency: currency,
      isVerified: isVerified,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      images: images.map((e) => e.toEntity()).toList(),
      propertyType: propertyType?.toEntity(),
      listingType: listingType?.toEntity(),
      attributes: attributes.map((e) => e.toEntity()).toList(),
      allowedBillingPeriods: allowedBillingPeriods
          .map((e) => e.toEntity())
          .toList(),
    );
  }
}

class AllowedBillingPeriodModel {
  final String propertyId;
  final int billingPeriodId;
  final PropertyBillingPeriodModel billingPeriod;

  AllowedBillingPeriodModel({
    required this.propertyId,
    required this.billingPeriodId,
    required this.billingPeriod,
  });

  factory AllowedBillingPeriodModel.fromJson(Map<String, dynamic> json) {
    return AllowedBillingPeriodModel(
      propertyId: json['propertyId'] as String? ?? '',
      billingPeriodId: (json['billingPeriodId'] as num?)?.toInt() ?? 0,
      billingPeriod: PropertyBillingPeriodModel.fromJson(
        json['billingPeriod'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  AllowedBillingPeriodEntity toEntity() {
    return AllowedBillingPeriodEntity(
      propertyId: propertyId,
      billingPeriodId: billingPeriodId,
      billingPeriod: billingPeriod.toEntity(),
    );
  }
}

class PropertyBillingPeriodModel {
  final int id;
  final String slug;
  final String label;
  final int durationMonths;

  PropertyBillingPeriodModel({
    required this.id,
    required this.slug,
    required this.label,
    required this.durationMonths,
  });

  factory PropertyBillingPeriodModel.fromJson(Map<String, dynamic> json) {
    return PropertyBillingPeriodModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      label: json['label'] as String? ?? '',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
    );
  }

  PropertyBillingPeriodEntity toEntity() {
    return PropertyBillingPeriodEntity(
      id: id,
      slug: slug,
      label: label,
      durationMonths: durationMonths,
    );
  }
}

class PropertyImageModel {
  final String url;
  final bool isPrimary;

  PropertyImageModel({required this.url, required this.isPrimary});

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      url: json['url'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  PropertyImageEntity toEntity() {
    return PropertyImageEntity(url: url, isPrimary: isPrimary);
  }
}

class PropertyTypeModel {
  final int id;
  final String slug;
  final String label;

  PropertyTypeModel({
    required this.id,
    required this.slug,
    required this.label,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  PropertyTypeEntity toEntity() {
    return PropertyTypeEntity(id: id, slug: slug, label: label);
  }
}

class ListingTypeModel {
  final int id;
  final String slug;
  final String label;

  ListingTypeModel({required this.id, required this.slug, required this.label});

  factory ListingTypeModel.fromJson(Map<String, dynamic> json) {
    return ListingTypeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  ListingTypeEntity toEntity() {
    return ListingTypeEntity(id: id, slug: slug, label: label);
  }
}

class PropertyAttributeModel {
  final String id;
  final String propertyId;
  final int attributeTypeId;
  final String value;
  final AttributeTypeModel? attributeType;

  PropertyAttributeModel({
    required this.id,
    required this.propertyId,
    required this.attributeTypeId,
    required this.value,
    required this.attributeType,
  });

  factory PropertyAttributeModel.fromJson(Map<String, dynamic> json) {
    return PropertyAttributeModel(
      id: json['id'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      attributeTypeId: (json['attributeTypeId'] as num?)?.toInt() ?? 0,
      value: json['value']?.toString() ?? '',
      attributeType: json['attributeType'] == null
          ? null
          : AttributeTypeModel.fromJson(
              json['attributeType'] as Map<String, dynamic>,
            ),
    );
  }

  PropertyAttributeEntity toEntity() {
    return PropertyAttributeEntity(
      id: id,
      propertyId: propertyId,
      attributeTypeId: attributeTypeId,
      value: value,
      attributeType: attributeType?.toEntity(),
    );
  }
}

class AttributeTypeModel {
  final int id;
  final String slug;
  final String label;
  final String dataType;
  final String iconUrl;

  AttributeTypeModel({
    required this.id,
    required this.slug,
    required this.label,
    required this.dataType,
    required this.iconUrl,
  });

  factory AttributeTypeModel.fromJson(Map<String, dynamic> json) {
    return AttributeTypeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String? ?? '',
      label: json['label'] as String? ?? '',
      dataType: json['dataType'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
    );
  }

  AttributeTypeEntity toEntity() {
    return AttributeTypeEntity(
      id: id,
      slug: slug,
      label: label,
      dataType: dataType,
      iconUrl: iconUrl,
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null) return null;
  try {
    return DateTime.tryParse(raw);
  } catch (_) {
    return null;
  }
}
