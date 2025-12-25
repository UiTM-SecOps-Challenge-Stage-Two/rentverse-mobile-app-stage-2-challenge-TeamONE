import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/features/property/domain/entity/create_property_params.dart';
import 'package:rentverse/features/property/domain/usecase/create_property_usecase.dart';

import 'add_property_state.dart';

class AddPropertyCubit extends Cubit<AddPropertyState> {
  AddPropertyCubit(this._createPropertyUseCase)
    : super(const AddPropertyState());

  final CreatePropertyUseCase _createPropertyUseCase;


  static const int _sizeAttributeId = 1;
  static const int _bedroomAttributeId = 2;
  static const int _bathroomAttributeId = 3;

  void setImages(List<String> paths) {
    emit(
      state.copyWith(
        imagePaths: paths.take(5).toList(),
        basicCompleted: _isBasicComplete(state.copyWith(imagePaths: paths)),
      ),
    );
  }

  void updateBasic({
    String? title,
    String? description,
    int? propertyTypeId,
    int? listingTypeId,
    String? projectName,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? size,
    int? bedrooms,
    int? bathrooms,
  }) {
    final next = state.copyWith(
      title: title ?? state.title,
      description: description ?? state.description,
      propertyTypeId: propertyTypeId ?? state.propertyTypeId,
      listingTypeId: listingTypeId ?? state.listingTypeId,
      projectName: projectName ?? state.projectName,
      address: address ?? state.address,
      city: city ?? state.city,
      country: country ?? state.country,
      latitude: latitude ?? state.latitude,
      longitude: longitude ?? state.longitude,
      size: size ?? state.size,
      bedrooms: bedrooms ?? state.bedrooms,
      bathrooms: bathrooms ?? state.bathrooms,
    );

    emit(next.copyWith(basicCompleted: _isBasicComplete(next)));
  }

  void resetBasic() {
    emit(
      state.copyWith(
        title: '',
        description: '',
        propertyTypeId: 1,
        listingTypeId: 1,
        projectName: '',
        address: '',
        city: '',
        country: 'Indonesia',
        latitude: null,
        longitude: null,
        size: '',
        bedrooms: 0,
        bathrooms: 0,
        basicCompleted: false,
      ),
    );
  }

  void updatePricing({
    String? furnishing,
    List<String>? features,
    List<String>? facilities,
    List<String>? views,
    List<int>? billingPeriodIds,
    String? price,
    int? listingTypeId,
  }) {
    final next = state.copyWith(
      furnishing: furnishing ?? state.furnishing,
      features: features ?? state.features,
      facilities: facilities ?? state.facilities,
      views: views ?? state.views,
      billingPeriodIds: billingPeriodIds ?? state.billingPeriodIds,
      price: price ?? state.price,
      listingTypeId: listingTypeId ?? state.listingTypeId,
    );

    emit(next.copyWith(pricingCompleted: _isPricingComplete(next)));
  }

  void resetPricing() {
    emit(
      state.copyWith(
        furnishing: 'Unfurnished',
        features: const [],
        facilities: const [],
        views: const [],
        billingPeriodIds: const [1],
        price: '',
        pricingCompleted: false,
      ),
    );
  }

  Future<void> submit() async {
    if (!_isBasicComplete(state)) {
      emit(
        state.copyWith(
          status: AddPropertyStatus.failure,
          error: 'Lengkapi Basic Property Information terlebih dahulu.',
        ),
      );
      return;
    }
    if (!_isPricingComplete(state)) {
      emit(
        state.copyWith(
          status: AddPropertyStatus.failure,
          error: 'Lengkapi Pricing & Amenity Details terlebih dahulu.',
        ),
      );
      return;
    }
    if (state.imagePaths.isEmpty) {
      emit(
        state.copyWith(
          status: AddPropertyStatus.failure,
          error: 'Tambah minimal 1 gambar (maks 5).',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AddPropertyStatus.loading, error: null));
    try {
      final params = _toParams(state);
      await _createPropertyUseCase(params);
      emit(state.copyWith(status: AddPropertyStatus.success, error: null));
    } catch (e) {
      emit(
        state.copyWith(status: AddPropertyStatus.failure, error: e.toString()),
      );
    }
  }

  bool _isBasicComplete(AddPropertyState value) {
    return value.title.length >= 5 &&
        value.propertyTypeId > 0 &&
        value.listingTypeId > 0 &&
        value.address.isNotEmpty &&
        value.city.isNotEmpty;
  }

  bool _isPricingComplete(AddPropertyState value) {
    return value.price.isNotEmpty && value.billingPeriodIds.isNotEmpty;
  }

  CreatePropertyParams _toParams(AddPropertyState value) {
    final amenities = <String>[
      ...value.features,
      ...value.facilities,
      ...value.views,
    ];
    if (value.furnishing.isNotEmpty) amenities.add(value.furnishing);

    final attributes = <Map<String, dynamic>>[];
    if (value.size.isNotEmpty) {
      attributes.add({
        'attributeTypeId': _sizeAttributeId,
        'value': value.size,
      });
    }
    if (value.bedrooms > 0) {
      attributes.add({
        'attributeTypeId': _bedroomAttributeId,
        'value': value.bedrooms.toString(),
      });
    }
    if (value.bathrooms > 0) {
      attributes.add({
        'attributeTypeId': _bathroomAttributeId,
        'value': value.bathrooms.toString(),
      });
    }

    return CreatePropertyParams(
      imageFilePaths: value.imagePaths,
      title: value.title,
      description: value.description.isEmpty ? null : value.description,
      propertyTypeId: value.propertyTypeId,
      listingTypeId: value.listingTypeId,
      price: value.price,
      currency: 'IDR',
      address: value.address,
      city: value.city,
      country: value.country,
      latitude: value.latitude,
      longitude: value.longitude,
      billingPeriodIds: value.billingPeriodIds,
      amenities: amenities.isEmpty ? null : amenities,
      attributes: attributes.isEmpty ? null : attributes,
    );
  }
}
