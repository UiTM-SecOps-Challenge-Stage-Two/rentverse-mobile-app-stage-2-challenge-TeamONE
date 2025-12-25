import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/features/property/domain/usecase/update_property_usecase.dart';
import 'package:rentverse/role/lanlord/widget/add_property/map_handling.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditPropertyPage extends StatefulWidget {
  const EditPropertyPage({super.key, required this.property});

  final PropertyEntity property;

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _projectController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _sizeController;


  late TextEditingController _priceController;
  String _furnishing = 'Unfurnished';
  List<String> _features = [];
  List<String> _facilities = [];
  List<String> _views = [];
  int _billingPeriodId = 1;
  int _listingTypeId = 1;

  int _propertyTypeId = 1;
  int _bedrooms = 0;
  int _bathrooms = 0;

  List<String> _images = const [];

  bool _isSubmitting = false;

  static const _propertyTypes = [
    {'id': 1, 'label': 'Apartment'},
    {'id': 2, 'label': 'House'},
    {'id': 3, 'label': 'Villa'},
  ];

  static const _billingOptions = [
    {'id': 1, 'label': 'Month to month'},
    {'id': 2, 'label': '3 months'},
    {'id': 3, 'label': '6 months'},
    {'id': 4, 'label': 'At least one year'},
  ];

  static const _furnishingOptions = [
    'Unfurnished',
    'Fully Furnished',
    'Partly Furnished',
    'Negotiable',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description);
    _projectController = TextEditingController(
      text: p.metadata?['projectName'] ?? '',
    );
    _addressController = TextEditingController(text: p.address);
    _cityController = TextEditingController(text: p.city);
    _countryController = TextEditingController(text: p.country);
    _sizeController = TextEditingController(text: p.metadata?['size'] ?? '');
    _priceController = TextEditingController(text: p.price);
    _propertyTypeId = p.propertyTypeId;
    _bedrooms = (p.metadata != null && p.metadata!['bedrooms'] is int)
        ? p.metadata!['bedrooms'] as int
        : 0;
    _bathrooms = (p.metadata != null && p.metadata!['bathrooms'] is int)
        ? p.metadata!['bathrooms'] as int
        : 0;
    _images = p.images.map((e) => e.url).whereType<String>().toList();
    _features = List<String>.from(p.metadata?['features'] ?? []);
    _facilities = List<String>.from(p.metadata?['facilities'] ?? []);
    _views = List<String>.from(p.metadata?['views'] ?? []);
    _furnishing = (p.metadata != null && p.metadata!['furnishing'] is String)
        ? p.metadata!['furnishing'] as String
        : _furnishing;
    _billingPeriodId = p.allowedBillingPeriods.isNotEmpty
        ? p.allowedBillingPeriods.first.billingPeriodId
        : 1;
    _listingTypeId = p.listingTypeId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result == null) return;
    final paths = result.paths.whereType<String>().take(10).toList();
    setState(() => _images = paths);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final fields = <String, dynamic>{};
      if (_titleController.text.trim().isNotEmpty)
        fields['title'] = _titleController.text.trim();
      if (_descriptionController.text.trim().isNotEmpty)
        fields['description'] = _descriptionController.text.trim();
      if (_priceController.text.trim().isNotEmpty) {
        fields['price'] =
            int.tryParse(
              _priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            _priceController.text.trim();
      }

      fields['propertyTypeId'] = _propertyTypeId;
      fields['listingTypeId'] = _listingTypeId;

      final metadata = <String, dynamic>{};
      if (_projectController.text.trim().isNotEmpty)
        metadata['projectName'] = _projectController.text.trim();
      if (_sizeController.text.trim().isNotEmpty)
        metadata['size'] = _sizeController.text.trim();
      metadata['bedrooms'] = _bedrooms;
      metadata['bathrooms'] = _bathrooms;
      if (_features.isNotEmpty) metadata['features'] = _features;
      if (_facilities.isNotEmpty) metadata['facilities'] = _facilities;
      if (_views.isNotEmpty) metadata['views'] = _views;
      metadata['furnishing'] = _furnishing;
      if (metadata.isNotEmpty) fields['metadata'] = metadata;


      if (_images.isNotEmpty) fields['images'] = _images;


      if (_addressController.text.trim().isNotEmpty)
        fields['address'] = _addressController.text.trim();
      if (_cityController.text.trim().isNotEmpty)
        fields['city'] = _cityController.text.trim();
      if (_countryController.text.trim().isNotEmpty)
        fields['country'] = _countryController.text.trim();

      fields['billingPeriodIds'] = [_billingPeriodId];

      final usecase = sl<UpdatePropertyUseCase>();
      final updated = await usecase(widget.property.id, fields);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully')),
      );
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledField(
                label: 'Title',
                controller: _titleController,
                hint: 'Stunning Studio Apartment...',
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'Describe the property',
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Property Type',
                value: _propertyTypeId,
                items: _propertyTypes,
                onChanged: (v) => setState(() => _propertyTypeId = v),
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Project / building name',
                controller: _projectController,
                hint: 'Project name',
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Address',
                controller: _addressController,
                hint: 'Full address',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'City',
                      controller: _cityController,
                      hint: 'City',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Country',
                      controller: _countryController,
                      hint: 'Country',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: MapPicker(
                  initialLat: widget.property.latitude ?? -6.2,
                  initialLon: widget.property.longitude ?? 106.816666,
                  onLocationSelected: (lat, lon, city, country, displayName) {
                    setState(() {
                      _addressController.text =
                          displayName ?? _addressController.text;
                      _cityController.text = city ?? _cityController.text;
                      _countryController.text =
                          country ?? _countryController.text;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Size (sqft)',
                controller: _sizeController,
                hint: '500',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _NumberStepper(
                label: 'Bedrooms',
                value: _bedrooms,
                onChanged: (v) => setState(() => _bedrooms = v),
              ),
              const SizedBox(height: 12),
              _NumberStepper(
                label: 'Bathrooms',
                value: _bathrooms,
                onChanged: (v) => setState(() => _bathrooms = v),
              ),
              const SizedBox(height: 16),
              _ImagePickerRow(images: _images, onPick: _pickImages),
              const SizedBox(height: 16),
              const Text(
                'Pricing & Amenity Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _furnishingOptions
                    .map(
                      (opt) => ChoiceChip(
                        label: Text(opt),
                        selected: _furnishing == opt,
                        onSelected: (_) => setState(() => _furnishing = opt),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _TagEditor(
                title: 'What are the features of your property?',
                values: _features,
                onChanged: (v) => setState(() => _features = v),
                suggestions: const [
                  'Private Lift',
                  'Private Gym',
                  'Swimming Pool',
                ],
              ),
              const SizedBox(height: 16),
              _TagEditor(
                title: 'Nearby facilities',
                values: _facilities,
                onChanged: (v) => setState(() => _facilities = v),
                suggestions: const ['Train Station', 'Bus Station'],
              ),
              const SizedBox(height: 16),
              _TagEditor(
                title: 'What are the views of your property?',
                values: _views,
                onChanged: (v) => setState(() => _views = v),
                suggestions: const ['Park View', 'Mountain View', 'City View'],
              ),
              const SizedBox(height: 16),
              const Text(
                'Billing period',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              ..._billingOptions.map(
                (opt) => RadioListTile<int>(
                  value: opt['id'] as int,
                  groupValue: _billingPeriodId,
                  onChanged: (val) {
                    if (val != null) setState(() => _billingPeriodId = val);
                  },
                  title: Text(opt['label'] as String),
                  dense: true,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Price (Rp)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '1.000.000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appSecondaryColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final int value;
  final List<Map<String, Object>> items;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e['id'] as int,
                  child: Text(e['label'] as String),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: Icon(LucideIcons.minus),
            ),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Icon(LucideIcons.plus),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  const _ImagePickerRow({required this.images, required this.onPick});
  final List<String> images;
  final VoidCallback onPick;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Images (max 10)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images.map((e) => Chip(label: Text(_fileName(e)))).toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: Icon(LucideIcons.upload),
          label: const Text('Select Images'),
        ),
      ],
    );
  }

  String _fileName(String path) {
    final parts = path.split('/');
    if (parts.isEmpty) return path;
    return parts.last;
  }
}

class _TagEditor extends StatefulWidget {
  const _TagEditor({
    required this.title,
    required this.values,
    required this.onChanged,
    this.suggestions = const [],
  });
  final String title;
  final List<String> values;
  final List<String> suggestions;
  final ValueChanged<List<String>> onChanged;
  @override
  State<_TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<_TagEditor> {
  late List<String> _current;
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _current = List<String>.from(widget.values);
  }

  @override
  void didUpdateWidget(covariant _TagEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values)
      _current = List<String>.from(widget.values);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _current
              .map(
                (e) => InputChip(label: Text(e), onDeleted: () => _remove(e)),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Add item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addFromInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CD8D2),
                minimumSize: const Size(60, 44),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: widget.suggestions
                .map(
                  (s) => ActionChip(label: Text(s), onPressed: () => _add(s)),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _addFromInput() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _add(text);
    _controller.clear();
  }

  void _add(String value) {
    if (_current.contains(value)) return;
    setState(() => _current.add(value));
    widget.onChanged(_current);
  }

  void _remove(String value) {
    setState(() => _current.remove(value));
    widget.onChanged(_current);
  }
}
