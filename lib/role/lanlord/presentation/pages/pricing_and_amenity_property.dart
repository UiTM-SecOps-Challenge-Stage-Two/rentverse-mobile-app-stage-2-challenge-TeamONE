import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/add_property_cubit.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/add_property_state.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PricingAndAmenityPropertyPage extends StatefulWidget {
  const PricingAndAmenityPropertyPage({super.key});

  @override
  State<PricingAndAmenityPropertyPage> createState() =>
      _PricingAndAmenityPropertyPageState();
}

class _PricingAndAmenityPropertyPageState
    extends State<PricingAndAmenityPropertyPage> {
  late String _furnishing;
  late List<String> _features;
  late List<String> _facilities;
  late List<String> _views;
  late List<int> _billingPeriodIds;
  late int _listingTypeId;
  late TextEditingController _priceController;

  static const _furnishingOptions = [
    'Unfurnished',
    'Fully Furnished',
    'Partly Furnished',
    'Negotiable',
  ];

  static const _billingOptions = [
    {'id': 1, 'label': 'Month to month'},
    {'id': 2, 'label': '3 months'},
    {'id': 3, 'label': '6 months'},
    {'id': 4, 'label': 'At least one year'},
  ];


  @override
  void initState() {
    super.initState();
    final state = context.read<AddPropertyCubit>().state;
    _furnishing = state.furnishing;
    _features = List<String>.from(state.features);
    _facilities = List<String>.from(state.facilities);
    _views = List<String>.from(state.views);
    _billingPeriodIds = List<int>.from(state.billingPeriodIds);
    if (_billingPeriodIds.isEmpty) _billingPeriodIds.add(1);
    _listingTypeId = state.listingTypeId;
    _priceController = TextEditingController(text: state.price);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Pricing & Amenity Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        elevation: 0,
      ),
      body: BlocBuilder<AddPropertyCubit, AddPropertyState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Furnishing Status'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _furnishingOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final opt = _furnishingOptions[index];
                      final isSelected = _furnishing == opt;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _furnishing = opt);
                          _pushChanges();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? appPrimaryColor.withOpacity(0.1)
                                : Colors.grey[50],
                            border: Border.all(
                              color: isSelected
                                  ? appSecondaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            opt,
                            style: TextStyle(
                              color: isSelected ? appSecondaryColor : Colors.black,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _TagEditor(
                  title: 'Property Features',
                  values: _features,
                  onChanged: (vals) {
                    setState(() => _features = vals);
                    _pushChanges();
                  },
                  suggestions: const [
                    'Private Lift',
                    'Private Gym',
                    'Swimming Pool',
                  ],
                ),
                const SizedBox(height: 24),
                _TagEditor(
                  title: 'Nearby Facilities',
                  values: _facilities,
                  onChanged: (vals) {
                    setState(() => _facilities = vals);
                    _pushChanges();
                  },
                  suggestions: const ['Train Station', 'Bus Station'],
                ),
                const SizedBox(height: 24),
                _TagEditor(
                  title: 'Property Views',
                  values: _views,
                  onChanged: (vals) {
                    setState(() => _views = vals);
                    _pushChanges();
                  },
                  suggestions: const [
                    'Park View',
                    'Mountain View',
                    'City View',
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Billing Period'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _billingOptions.map((opt) {
                    final id = opt['id'] as int;
                    final isSelected = _billingPeriodIds.contains(id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_billingPeriodIds.length > 1) {
                                _billingPeriodIds.remove(id);
                            }
                          } else {
                            _billingPeriodIds.add(id);
                          }
                        });
                        _pushChanges();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? appPrimaryColor.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? appSecondaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          opt['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? appSecondaryColor
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Price (Rp)'),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '',
                    prefixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Rp ',
                          style: TextStyle(
                            color: appSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: appSecondaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: appSecondaryColor, width: 2),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (_) => _pushChanges(),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
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
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 52,
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
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  void _pushChanges() {
    context.read<AddPropertyCubit>().updatePricing(
          furnishing: _furnishing,
          features: _features,
          facilities: _facilities,
          views: _views,
          billingPeriodIds: _billingPeriodIds,
          price: _priceController.text,
          listingTypeId: _listingTypeId,
        );
  }

  void _reset() {
    context.read<AddPropertyCubit>().resetPricing();
    final state = context.read<AddPropertyCubit>().state;
    setState(() {
      _furnishing = state.furnishing;
      _features = List<String>.from(state.features);
      _facilities = List<String>.from(state.facilities);
      _views = List<String>.from(state.views);
      _billingPeriodIds = List<int>.from(state.billingPeriodIds);
      if (_billingPeriodIds.isEmpty) _billingPeriodIds.add(1);

      _listingTypeId = state.listingTypeId;
      _priceController.text = state.price;
    });
  }

  void _save() {
    _pushChanges();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pricing & amenities saved')),
    );
    Navigator.of(context).maybePop();
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
    if (oldWidget.values != widget.values) {
      _current = List<String>.from(widget.values);
    }
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
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_current.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _current.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: appPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: appSecondaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e,
                      style: const TextStyle(
                        color: appSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _remove(e),
                      child: Icon(LucideIcons.x,
                          size: 16, color: appSecondaryColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add new item...',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: appSecondaryColor),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: customLinearGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addFromInput,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(LucideIcons.plus, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Suggestions:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.suggestions
                .where((s) => !_current.contains(s))
                .map(
                  (s) => GestureDetector(
                    onTap: () => _add(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '+ $s',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
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
