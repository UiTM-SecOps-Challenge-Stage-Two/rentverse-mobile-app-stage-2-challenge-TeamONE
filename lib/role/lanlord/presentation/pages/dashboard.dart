import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rentverse/common/widget/custom_app_bar.dart';
import 'package:rentverse/role/lanlord/widget/dashboard/property_being_proposed.dart';
import 'package:rentverse/role/lanlord/widget/dashboard/rented_property.dart';
import 'package:rentverse/role/lanlord/widget/dashboard/stats_widget.dart';
import 'package:rentverse/role/lanlord/widget/dashboard/your_trust_index.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/role/lanlord/domain/entity/dashboard_entity_response.dart';
import 'package:rentverse/role/lanlord/domain/usecase/get_landlord_dashboard_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/get_local_user_usecase.dart';
import 'package:intl/intl.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/property/cubit.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/property/state.dart';
import 'package:rentverse/common/utils/network_utils.dart';
import 'package:rentverse/common/widget/pull_to_refresh.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/dashboard/landlord_dashboard_cubit.dart';
import 'package:rentverse/role/lanlord/presentation/cubit/dashboard/landlord_dashboard_state.dart';
import 'package:rentverse/features/notification/presentation/pages/notification_page.dart';

class LandlordDashboardPage extends StatefulWidget {
  const LandlordDashboardPage({super.key});

  @override
  State<LandlordDashboardPage> createState() => _LandlordDashboardPageState();
}

class _LandlordDashboardPageState extends State<LandlordDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LandlordDashboardCubit(
            sl<GetLocalUserUseCase>(),
            sl<GetLandlordDashboardUseCase>(),
          )..load(),
        ),
        BlocProvider(create: (_) => LandlordPropertyCubit(sl())..load()),
      ],
      child: _LandlordDashboardView(),
    );
  }
}

class _LandlordDashboardView extends StatelessWidget {
  const _LandlordDashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandlordDashboardCubit, LandlordDashboardState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              displayName: state.user?.name ?? 'Landlord',
              onNotificationTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),
            body: NotificationListener<ReloadDataNotification>(
              onNotification: (n) {
                context.read<LandlordDashboardCubit>().refresh();
                return true;
              },
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LandlordDashboardState state) {
    if (state.status == LandlordDashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == LandlordDashboardStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load dashboard: ${state.errorMessage ?? ''}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<LandlordDashboardCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final overview = state.dashboard?.overview;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _DashboardWalletCard(totalIncome: overview?.totalIncome),
          const SizedBox(height: 16),
          StatsWidget(
            periods: const ['Monthly', 'Weekly', 'Daily'],
            selectedPeriod: 'Monthly',
            items: [
              StatItem(
                icon: LucideIcons.pieChart,
                title: overview?.occupancy.label ?? 'Occupancy',
                value: (overview?.occupancy.active ?? 0).toString(),
                delta: '${overview?.occupancy.pending ?? 0} pending',
              ),
              StatItem(
                icon: LucideIcons.building,
                title: overview?.inventory.label ?? 'Listed Properties',
                value: (overview?.inventory.total ?? 0).toString(),
                delta: '',
              ),
            ],
          ),
          const SizedBox(height: 16),

          YourTrustIndex(score: (overview?.trust.score ?? 0).toDouble()),
          const SizedBox(height: 16),
          const SizedBox(height: 16),

          BlocBuilder<LandlordPropertyCubit, LandlordPropertyState>(
            builder: (context, propsState) {
              if (propsState.status == LandlordPropertyStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (propsState.status == LandlordPropertyStatus.failure) {
                return Center(child: Text('Failed to load properties'));
              }

              final proposed =
                  propsState.items.where((p) => p.isVerified == false).toList();

              if (proposed.isEmpty) {
                return const SizedBox();
              }

              return PropertyBeingProposed(
                items: proposed
                    .map(
                      (p) => PropertyProposal(
                        title: p.title,
                        city: p.city,
                        imageUrl: makeDeviceAccessibleUrl(p.image),
                        status: 'Waiting',
                        statusBackground: Colors.orange,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          BlocBuilder<LandlordPropertyCubit, LandlordPropertyState>(
            builder: (context, propsState) {
              if (propsState.status == LandlordPropertyStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (propsState.status == LandlordPropertyStatus.failure) {
                return Center(child: Text('Failed to load properties'));
              }

              final rented = propsState.items
                  .where((p) => p.stats.totalBookings > 0)
                  .toList();

              if (rented.isEmpty) return const SizedBox();

              return RentedProperty(
                items: rented
                    .map(
                      (p) => RentedItem(
                        renterName: '—',
                        renterAvatarUrl: null,
                        title: p.title,
                        city: p.city,
                        startDate: p.createdAt != null
                            ? DateFormat('dd/MM/yyyy').format(p.createdAt!)
                            : '-',
                        endDate: '-',
                        duration: '${p.stats.totalBookings} bookings',
                        imageUrl: makeDeviceAccessibleUrl(p.image),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardWalletCard extends StatelessWidget {
  const _DashboardWalletCard({this.totalIncome});

  final TotalIncomeEntity? totalIncome;

  String _formatAmount(num? amount, String? currency) {
    final v = (amount ?? 0).toDouble();
    try {
      final f = NumberFormat.currency(
        locale: 'id_ID',
        symbol: (currency == null || currency.isEmpty) ? 'Rp ' : '$currency ',
        decimalDigits: 0,
      );
      return f.format(v);
    } catch (_) {
      return '${currency ?? ''} ${v.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: customLinearGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalIncome?.currency ?? 'IDR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatAmount(totalIncome?.amount, totalIncome?.currency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
