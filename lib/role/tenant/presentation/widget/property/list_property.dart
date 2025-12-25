import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/utils/network_utils.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/role/tenant/presentation/cubit/list_property/cubit.dart';
import 'package:rentverse/role/tenant/presentation/cubit/list_property/state.dart';
import 'package:rentverse/role/tenant/presentation/pages/property/detail_property.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ListPropertyWidget extends StatelessWidget {
  const ListPropertyWidget({super.key, this.limitToThree = false});

  final bool limitToThree;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyCubit, ListPropertyState>(
      builder: (context, state) {
        return _buildPropertyList(
          context,
          state.items,
          state.isLoading,
          state.isLoadingMore,
          state.hasMore,
          limitToThree);
      });
  }
}


Widget _buildPropertyList(
  BuildContext context,
  List<PropertyEntity> items,
  bool isLoading,
  bool isLoadingMore,
  bool hasMore,
  bool limitToThree) {
  if (isLoading && items.isEmpty) {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()));
  }

  if (items.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'No properties found',
          style: TextStyle(color: Colors.grey))));
  }

  final visibleItems = limitToThree ? items.take(3).toList() : items;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Featured Property',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(
              'View All',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 13,
                fontWeight: FontWeight.w600))])),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleItems.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (isLoadingMore && index == visibleItems.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()));
          }
          final property = visibleItems[index];
          return _buildPropertyItem(context, property);
        })]);
}


Widget _buildPropertyItem(BuildContext context, PropertyEntity property) {
  String? imageUrl;
  if (property.images.isNotEmpty) {
    final primary = property.images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => property.images.first);
    imageUrl = primary.url.isNotEmpty ? primary.url : null;
  }
  final attrBed = property.attributes.firstWhere(
    (a) => a.attributeType?.slug == 'bedroom',
    orElse: () => const PropertyAttributeEntity(
      id: '',
      propertyId: '',
      attributeTypeId: 0,
      value: '',
      attributeType: null));
  final beds = attrBed.value.isNotEmpty ? attrBed.value : '-';

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailProperty(property: property))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 96,
                height: 86,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: makeDeviceAccessibleUrl(imageUrl) ?? imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, _) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (c, _, __) => const _ImageUnavailableBox(
                          message: 'Failed to load image'))
                    : const _ImageUnavailableBox(message: 'No image available'))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin,
                        size: 14,
                        color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.city}, ${property.country}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey)))]),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${property.price}/mon',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.bed, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$beds', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.bath, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('1', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.square,
                        size: 14,
                        color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('500 Sqft', style: TextStyle(fontSize: 12))])]))]))));
}

class _ImageUnavailableBox extends StatelessWidget {
  const _ImageUnavailableBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w600))));
  }
}
