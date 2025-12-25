import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/add_property_cubit.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/add_property_state.dart';
import 'package:rentverse/role/lanlord/widget/add_property/map_handling.dart';
import 'package:rentverse/features/map/presentation/screen/open_map_screen.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddPropertyBasicPage extends StatefulWidget {
  const AddPropertyBasicPage({super.key});

  @override
  State<AddPropertyBasicPage> createState() => _AddPropertyBasicPageState();
}

class _AddPropertyBasicPageState extends State<AddPropertyBasicPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _projectController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _sizeController;

  int _propertyTypeId = 1;
  int _listingTypeId = 1;
  int _bedrooms = 0;
  int _bathrooms = 0;
  List<String> _images = const [];

  static const _propertyTypes = [
    {'id': 1, 'label': 'Apartment'},
    {'id': 2, 'label': 'House'},
    {'id': 3, 'label': 'Villa'},
  ];

  static const _listingTypes = [
    {'id': 1, 'label': 'Rent'},
    {'id': 2, 'label': 'Sell'},
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<AddPropertyCubit>().state;
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description);
    _projectController = TextEditingController(text: state.projectName);
    _addressController = TextEditingController(text: state.address);
    _cityController = TextEditingController(text: state.city);
    _countryController = TextEditingController(text: state.country);
    _sizeController = TextEditingController(text: state.size);
    _propertyTypeId = state.propertyTypeId;
    _listingTypeId = state.listingTypeId;
    _bedrooms = state.bedrooms;
    _bathrooms = state.bathrooms;
    _images = state.imagePaths;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Basic Property Information'),
        centerTitle: true,
      ),
      body: BlocBuilder<AddPropertyCubit, AddPropertyState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledField(
                  label: 'Enter an appealing title for this property listing',
                  controller: _titleController,
                  hint: 'Stunning Studio Apartment...',
                  onChanged: (_) => _onChange(),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Provide a detailed description of this property unit',
                  controller: _descriptionController,
                  hint: 'Describe the property',
                  maxLines: 3,
                  onChanged: (_) => _onChange(),
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'What type of property are you listing?',
                  value: _propertyTypeId,
                  items: _propertyTypes,
                  onChanged: (val) {
                    setState(() => _propertyTypeId = val);
                    _onChange();
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Listing type',
                  value: _listingTypeId,
                  items: _listingTypes,
                  onChanged: (val) {
                    setState(() => _listingTypeId = val);
                    _onChange();
                  },
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Project / building name',
                  controller: _projectController,
                  hint: 'Bandaraya Georgetown...',
                  onChanged: (_) => _onChange(),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Your property address',
                  controller: _addressController,
                  hint: 'Address',
                  onChanged: (_) => _onChange(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'City',
                        controller: _cityController,
                        hint: 'City',
                        onChanged: (_) => _onChange(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: 'Country',
                        controller: _countryController,
                        hint: 'Country',
                        onChanged: (_) => _onChange(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: state.latitude != null && state.longitude != null
                      ? MapPreview(
                          lat: state.latitude!,
                          lon: state.longitude!,
                          displayName: state.address.isNotEmpty
                              ? state.address
                              : null,
                          onTap: () async {
                            final result = await Navigator.of(context)
                                .push<Map<String, dynamic>>(
                                  MaterialPageRoute(
                                    builder: (_) => OpenMapScreen(
                                      initialLat: state.latitude ?? -6.200000,
                                      initialLon: state.longitude ?? 106.816666,
                                    ),
                                  ),
                                );
                            if (result == null) return;
                            final lat = (result['lat'] as num).toDouble();
                            final lon = (result['lon'] as num).toDouble();
                            final displayName =
                                result['displayName'] as String?;
                            final city = result['city'] as String?;
                            final country = result['country'] as String?;
                            context.read<AddPropertyCubit>().updateBasic(
                              address: displayName ?? state.address,
                              city: city ?? state.city,
                              country: country ?? state.country,
                              latitude: lat,
                              longitude: lon,
                            );
                            setState(() {
                              _addressController.text =
                                  displayName ?? _addressController.text;
                              _cityController.text =
                                  city ?? _cityController.text;
                              _countryController.text =
                                  country ?? _countryController.text;
                            });
                          },
                        )
                      : MapPicker(
                          initialLat: state.latitude ?? -6.200000,
                          initialLon: state.longitude ?? 106.816666,
                          onLocationSelected:
                              (lat, lon, city, country, displayName) {

                                context.read<AddPropertyCubit>().updateBasic(
                                  address: displayName ?? state.address,
                                  city: city ?? state.city,
                                  country: country ?? state.country,
                                  latitude: lat,
                                  longitude: lon,
                                );
                                setState(() {
                                  _addressController.text =
                                      displayName ?? _addressController.text;
                                  _cityController.text =
                                      city ?? _cityController.text;
                                  _countryController.text =
                                      country ?? _countryController.text;
                                });
                              },
                        ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'What is the size of this property? (sqft)',
                  controller: _sizeController,
                  hint: '500',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _onChange(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _NumberStepper(
                        label: 'Bedrooms',
                        value: _bedrooms,
                        onChanged: (v) {
                          setState(() => _bedrooms = v);
                          _onChange();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberStepper(
                        label: 'Bathrooms',
                        value: _bathrooms,
                        onChanged: (v) {
                          setState(() => _bathrooms = v);
                          _onChange();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ImagePickerRow(images: _images, onPick: _pickImages),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: customLinearGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _reset,
                              borderRadius: BorderRadius.circular(10),
                              child: const Center(
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: appSecondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: customLinearGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _save,
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result == null) return;
    final paths = result.paths.whereType<String>().take(5).toList();
    setState(() => _images = paths);
    context.read<AddPropertyCubit>().setImages(paths);
  }

  void _reset() {
    context.read<AddPropertyCubit>().resetBasic();
    final state = context.read<AddPropertyCubit>().state;
    setState(() {
      _titleController.text = state.title;
      _descriptionController.text = state.description;
      _projectController.text = state.projectName;
      _addressController.text = state.address;
      _cityController.text = state.city;
      _countryController.text = state.country;
      _sizeController.text = state.size;
      _propertyTypeId = state.propertyTypeId;
      _listingTypeId = state.listingTypeId;
      _bedrooms = state.bedrooms;
      _bathrooms = state.bathrooms;
      _images = state.imagePaths;
    });
  }

  void _save() {
    context.read<AddPropertyCubit>().updateBasic(
      title: _titleController.text,
      description: _descriptionController.text,
      propertyTypeId: _propertyTypeId,
      listingTypeId: _listingTypeId,
      projectName: _projectController.text,
      address: _addressController.text,
      city: _cityController.text,
      country: _countryController.text,
      size: _sizeController.text,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
    );
    context.read<AddPropertyCubit>().setImages(_images);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Basic info saved')));
    Navigator.of(context).maybePop();
  }

  void _onChange() {
    context.read<AddPropertyCubit>().updateBasic(
      title: _titleController.text,
      description: _descriptionController.text,
      propertyTypeId: _propertyTypeId,
      listingTypeId: _listingTypeId,
      projectName: _projectController.text,
      address: _addressController.text,
      city: _cityController.text,
      country: _countryController.text,
      size: _sizeController.text,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
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
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appSecondaryColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: appSecondaryColor, width: 2),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: appSecondaryColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: appSecondaryColor, width: 2),
            ),
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
        const SizedBox(height: 10),
        Row(
          children: [
            _StepperButton(
              icon: LucideIcons.minus,
              onTap: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Container(
              alignment: Alignment.center,
              width: 50,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            _StepperButton(
              icon: LucideIcons.plus,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? appSecondaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isEnabled ? Colors.white : Colors.grey.shade100,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? appSecondaryColor : Colors.grey.shade400,
          ),
        ),
      ),
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
          'Upload Images (max 5)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (images.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.map((path) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: customLinearGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.upload, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Select Images',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


}
