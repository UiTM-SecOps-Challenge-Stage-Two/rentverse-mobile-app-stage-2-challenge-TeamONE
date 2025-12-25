

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/property/domain/entity/list_property_entity.dart';
import 'package:rentverse/features/chat/presentation/pages/chat_room_page.dart';
import 'package:rentverse/features/chat/domain/usecase/start_chat_usecase.dart';
import 'package:rentverse/common/bloc/auth/auth_cubit.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/common/utils/network_utils.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/amenities_widget.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/accessorise_widget.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/image_tile.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/owner_contact.dart';
import 'package:rentverse/role/tenant/presentation/widget/detail_property/booking_button.dart';
import 'package:rentverse/features/review/presentation/widget/property_reviews_widget.dart';
import 'package:rentverse/features/bookings/presentation/widget/property_availability_widget.dart';
import 'package:rentverse/role/tenant/presentation/pages/property/booking_property.dart';
import 'package:rentverse/role/tenant/presentation/cubit/detail_property/cubit.dart';
import 'package:rentverse/role/tenant/presentation/cubit/detail_property/state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DetailProperty extends StatelessWidget {
  const DetailProperty({super.key, required this.property});

  final PropertyEntity property;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailPropertyCubit(sl())..fetch(property.id),
      child: BlocConsumer<DetailPropertyCubit, DetailPropertyState>(
        listener: (context, state) {
          if (state.status == DetailPropertyStatus.failure &&
              state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final currentProperty = state.property ?? property;
          final isLoading =
              state.status == DetailPropertyStatus.loading &&
              state.property == null;

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  currentProperty.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                backgroundColor: Colors.transparent,
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ImageTile(images: currentProperty.images),
                        AccessoriseWidget(
                          attributes: currentProperty.attributes,
                        ),
                        const SizedBox(height: 10),
                        OwnerContact(
                          landlordId: currentProperty.landlordId,
                          ownerName: _extractOwnerName(currentProperty),
                          avatarUrl: makeDeviceAccessibleUrl(
                            _extractOwnerAvatar(currentProperty),
                          ),
                          onChat: () => _startChat(context, currentProperty),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentProperty.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              AmenitiesWidget(
                                amenities: currentProperty.amenities,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _LocationMap(property: currentProperty),
                              const SizedBox(height: 12),

                              PropertyAvailabilityWidget(
                                propertyId: currentProperty.id,
                              ),
                              const SizedBox(height: 12),
                              PropertyReviewsWidget(
                                propertyId: currentProperty.id,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
              bottomNavigationBar: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  bool canBook = false;
                  if (authState is Authenticated) {
                    final user = authState.user;
                    if (user.isTenant) {
                      final kyc = user.tenantProfile?.kycStatus ?? '';
                      canBook = kyc.toUpperCase() == 'VERIFIED';
                    }
                  }

                  return BookingButton(
                    price: currentProperty.price,
                    onTap: canBook
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookingPropertyPage(
                                  property: currentProperty,
                                ),
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _startChat(BuildContext context, PropertyEntity property) async {
  final authState = context.read<AuthCubit>().state;
  if (authState is! Authenticated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda perlu login untuk memulai chat')),
    );
    return;
  }

  try {
    final roomId = await sl<StartChatUseCase>()(property.id);
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          roomId: roomId,
          otherUserName: _extractOwnerName(property) ?? 'Owner',
          otherUserAvatar: _extractOwnerAvatar(property),
          propertyTitle: property.title,
          currentUserId: authState.user.id,
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal memulai chat: $e')));
  }
}

String? _extractOwnerName(PropertyEntity property) {
  final meta = property.metadata ?? {};
  final byKey = meta['landlordName'] ?? meta['ownerName'];
  if (byKey is String && byKey.trim().isNotEmpty) return byKey.trim();
  return null;
}

String? _extractOwnerAvatar(PropertyEntity property) {
  final meta = property.metadata ?? {};
  final avatar = meta['landlordAvatar'] ?? meta['ownerAvatar'];
  if (avatar is String && avatar.trim().isNotEmpty) return avatar.trim();
  return null;
}

class _LocationMap extends StatelessWidget {
  const _LocationMap({required this.property});

  final PropertyEntity property;

  @override
  Widget build(BuildContext context) {
    final lat = property.latitude;
    final lon = property.longitude;

    if (lat == null || lon == null) {
      return const Text(
        'Lokasi belum tersedia',
        style: TextStyle(color: Colors.grey),
      );
    }

    final center = LatLng(lat, lon);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.mapPin, color: appSecondaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${property.city}, ${property.country}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.rentverse',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 40,
                      height: 40,
                      child: Icon(LucideIcons.mapPin,
                        size: 40,
                        color: appSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
