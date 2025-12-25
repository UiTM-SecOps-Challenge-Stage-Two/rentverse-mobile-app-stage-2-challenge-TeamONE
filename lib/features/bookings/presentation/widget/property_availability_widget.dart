import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/bookings/domain/usecase/get_property_availability_usecase.dart';
import 'package:logger/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';

class _AvailabilityItem {
  final DateTime start;
  final DateTime end;
  final String? reason;

  _AvailabilityItem({required this.start, required this.end, this.reason});
}

class PropertyAvailabilityWidget extends StatefulWidget {
  final String propertyId;
  const PropertyAvailabilityWidget({super.key, required this.propertyId});

  @override
  State<PropertyAvailabilityWidget> createState() =>
      _PropertyAvailabilityWidgetState();
}

class _PropertyAvailabilityWidgetState
    extends State<PropertyAvailabilityWidget> {
  bool _loading = false;
  String? _error;
  List<_AvailabilityItem> _ranges = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final usecase = sl<GetPropertyAvailabilityUseCase>();
      final logger = Logger();
      final res = await usecase(param: widget.propertyId);

      logger.i(
        'Loaded ${res.length} availability ranges for property ${widget.propertyId}',
      );

      setState(() {
        _ranges = res
            .map(
              (e) => _AvailabilityItem(
                start: e.start,
                end: e.end,
                reason: e.reason,
              ),
            )
            .toList();
      });
    } catch (e, st) {
      Logger().e(
        'Failed to load availability for ${widget.propertyId}: $e\n$st',
      );
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: const [
              Icon(
                LucideIcons.calendar,
                size: 18,
                color: Colors.black87,
              ),
              SizedBox(width: 8),
              Text(
                'Unavailable Dates',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),


        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),


        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Text(
              'Gagal memuat ketersediaan: $_error',
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),


        if (!_loading && _ranges.isEmpty && _error == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.check, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Properti tersedia sepenuhnya',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),


        if (_ranges.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(3, (i) {
                    final month = DateTime(
                      DateTime.now().year,
                      DateTime.now().month + i,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildMonthCalendar(month),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Container(width: 12, height: 12, color: Colors.grey.shade300),
                  const SizedBox(width: 8),
                  const Text('Tidak tersedia', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Container(
                    width: 12,
                    height: 12,
                    color: Colors.transparent,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tersedia', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMonthCalendar(DateTime month) {

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;


    final firstWeekday = firstOfMonth.weekday % 7;


    final totalCells = ((firstWeekday + daysInMonth) / 7).ceil() * 7;

    List<DateTime?> cells = List.generate(totalCells, (index) {
      final dayIndex = index - firstWeekday + 1;
      if (dayIndex < 1 || dayIndex > daysInMonth) return null;
      return DateTime(month.year, month.month, dayIndex);
    });

    return Container(
      width: 260,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(firstOfMonth),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (e) => Expanded(
                    child: Center(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, idx) {
              final date = cells[idx];
              if (date == null) return const SizedBox.shrink();

              final unavailable = _isDateUnavailable(date);

              return Container(
                decoration: BoxDecoration(
                  color: unavailable
                      ? Colors.grey.shade300
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: unavailable
                          ? Colors.grey.shade700
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isDateUnavailable(DateTime date) {
    for (final r in _ranges) {

      final d = DateTime(date.year, date.month, date.day);
      final s = DateTime(r.start.year, r.start.month, r.start.day);
      final e = DateTime(r.end.year, r.end.month, r.end.day);
      if (!d.isBefore(s) && !d.isAfter(e)) return true;
    }
    return false;
  }
}
