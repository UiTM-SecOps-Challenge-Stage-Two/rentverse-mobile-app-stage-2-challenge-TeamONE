import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/common/utils/network_utils.dart';


class ImageTile extends StatefulWidget {
  const ImageTile({super.key, required this.images});

  final List<PropertyImageEntity> images;

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _resolveInitialIndex();
  }

  int _resolveInitialIndex() {
    final primaryIndex = widget.images.indexWhere((img) => img.isPrimary);
    if (primaryIndex >= 0) return primaryIndex;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _emptyState();
    }

    final selected = widget.images[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _networkImage(selected.url),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final image = widget.images[index];
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.teal : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 92,
                      height: 72,
                      child: _networkImage(image.url),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _networkImage(String url) {
    if (url.isEmpty) {
      return _fallbackBox('No image available');
    }
    final processed = makeDeviceAccessibleUrl(url) ?? url;
    return CachedNetworkImage(
      imageUrl: processed,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => _fallbackBox('Failed to load image'),
    );
  }

  Widget _fallbackBox(String message) => Container(
    color: Colors.grey.shade200,
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _emptyState() => Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(child: Text('No images available')),
  );
}
