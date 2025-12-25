import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/bookings/domain/entity/res/booking_list_entity.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/features/property/domain/usecase/get_property_detail_usecase.dart';
import 'package:rentverse/features/auth/presentation/widget/custom_button.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/owner_contact.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/accessorise_widget.dart';
import 'package:rentverse/role/tenant/presentation/cubit/rent/active_rent_detail_cubit.dart';
import 'package:rentverse/role/tenant/presentation/cubit/rent/active_rent_detail_state.dart';
import 'package:rentverse/role/tenant/presentation/widget/review/review_widget.dart';
import 'package:rentverse/features/disputes/presentation/pages/create_dispute_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActiveRentDetailPage extends StatelessWidget {
  const ActiveRentDetailPage({super.key, required this.booking});

  final BookingListItemEntity booking;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ActiveRentDetailCubit(sl<GetPropertyDetailUseCase>())
          ..load(booking.property.id),
        child: _ActiveRentDetailView(booking: booking));
  }
}

class _ActiveRentDetailView extends StatelessWidget {
  const _ActiveRentDetailView({required this.booking});

  final BookingListItemEntity booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            leading: IconButton(
                icon: Icon(LucideIcons.arrowLeft),
                onPressed: () => Navigator.of(context).maybePop()),
            title: const Text('My Booking',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
            centerTitle: true),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 2,
            selectedItemColor: const Color(0xFF1CD8D2),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              if (index == 2) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.building), label: 'Property'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.receipt), label: 'Rent'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.messageSquare), label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(LucideIcons.user), label: 'Profile')
            ]),
        body: BlocBuilder<ActiveRentDetailCubit, ActiveRentDetailState>(
            builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          final property = state.property;
          if (property == null) {
            return const Center(child: Text('No property data'));
          }

          return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PropertyCard(property: property, booking: booking),
                    const SizedBox(height: 16),
                    _DetailCard(property: property, booking: booking),
                    const SizedBox(height: 16),
                    _ActionBar(booking: booking, onExtend: () {})
                  ]));
        }));
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.booking});

  final PropertyEntity property;
  final BookingListItemEntity booking;

  String _primaryImage() {
    if (property.images.isEmpty) return booking.property.image;
    final primary = property.images.firstWhere((img) => img.isPrimary,
        orElse: () => property.images.first);
    return primary.url;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(_primaryImage(), fit: BoxFit.cover))),
          const SizedBox(height: 12),
          Text(property.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(LucideIcons.mapPin, size: 16),
            const SizedBox(width: 4),
            Expanded(
                child: Text(property.city,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis))
          ]),
          const SizedBox(height: 10),
          AccessoriseWidget(attributes: property.attributes),
          const SizedBox(height: 10),
          OwnerContact(
              landlordId: property.landlordId,
              ownerName: property.landlord?.name,
              avatarUrl: property.landlord?.avatarUrl,
              onCall: () {},
              onChat: () {})
        ]));
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.property, required this.booking});

  final PropertyEntity property;
  final BookingListItemEntity booking;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _durationText() {
    if (booking.startDate == null || booking.endDate == null) return '-';
    final days = booking.endDate!.difference(booking.startDate!).inDays;
    return days <= 0 ? '-' : '$days Days';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(LucideIcons.home, color: Color(0xFF1CD8D2)),
            const SizedBox(width: 8),
            const Text('Property & Rent Details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(width: 8),
            _BlinkingDot()
          ]),
          const SizedBox(height: 12),
          _DetailRow(
              icon: LucideIcons.mapPin,
              label: 'Location',
              value: '${property.city}, ${property.country}'),
          const SizedBox(height: 12),
          _DetailRow(
              icon: LucideIcons.calendarDays,
              label: 'Starting Date',
              value: _formatDate(booking.startDate)),
          const SizedBox(height: 12),
          _DetailRow(
              icon: LucideIcons.calendarDays,
              label: 'Finish Date',
              value: _formatDate(booking.endDate)),
          const SizedBox(height: 12),
          _DetailRow(
              icon: LucideIcons.hourglass,
              label: 'Duration',
              value: _durationText()),
          const SizedBox(height: 12),
          _DetailRow(
              icon: LucideIcons.building,
              label: 'Property Type',
              value: property.propertyType?.label ?? '-')
        ]));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Colors.black54),
      const SizedBox(width: 10),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey))
      ]))
    ]);
  }
}

class _ActionBar extends StatefulWidget {
  const _ActionBar({required this.booking, required this.onExtend});

  final BookingListItemEntity booking;
  final VoidCallback onExtend;

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  bool _alreadyReviewed = false;
  bool _justDisputed = false;

  Future<void> _handleReview() async {
    final outcome = await showReviewDialog(context,
        bookingId: widget.booking.id, propertyId: widget.booking.property.id);

    if (outcome == ReviewOutcome.submitted ||
        outcome == ReviewOutcome.alreadyReviewed) {
      setState(() => _alreadyReviewed = true);
      if (outcome == ReviewOutcome.submitted) {

      }
    }
  }

  Future<void> _openDispute() async {
    final submitted = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) =>
            CreateDisputePage.withProvider(bookingId: widget.booking.id)));

    if (submitted == true && mounted) {
      setState(() => _justDisputed = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Dispute submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.booking.status.toUpperCase();
    final isFinished = status == 'FINISHED';
    final isActive = status == 'ACTIVE';

    final reviewLabel = _alreadyReviewed ? 'View Review' : 'Review';
    final reviewAction = _alreadyReviewed
        ? () => showReviewsBottomSheet(context, widget.booking.property.id)
        : _handleReview;

    if (isFinished) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CustomButton(text: 'Raise Dispute', onTap: _openDispute),
        const SizedBox(height: 10),
        CustomButton(text: reviewLabel, onTap: reviewAction),
        if (_justDisputed)
          const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Dispute submitted. We will follow up soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.green)))
      ]);
    }

    if (isActive) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CustomButton(text: 'Extend', onTap: widget.onExtend),
        const SizedBox(height: 10),
        CustomButton(text: 'Raise Dispute', onTap: _openDispute),
        const SizedBox(height: 10),
        CustomButton(text: reviewLabel, onTap: reviewAction),
        if (_justDisputed)
          const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Dispute submitted. We will follow up soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.green)))
      ]);
    }

    return CustomButton(text: 'Extend', onTap: widget.onExtend);
  }
}

class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
        lowerBound: 0.4,
        upperBound: 1.0)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _controller,
        child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
                color: Color(0xFF1CD8D2), shape: BoxShape.circle)));
  }
}
