import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/wallet/presentation/cubit/cubit.dart';
import 'package:rentverse/features/wallet/presentation/cubit/state.dart';
import 'package:rentverse/features/wallet/domain/entity/my_wallet_response_entity.dart';
import 'package:rentverse/features/wallet/presentation/pages/request_payout_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyWalletPage extends StatelessWidget {
  const MyWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletCubit(sl())..loadWallet(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.history),
            onPressed: () {

            },
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state.status == WalletStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == WalletStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.alertCircle, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load wallet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WalletCubit>().loadWallet(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final wallet = state.wallet;
          if (wallet == null) {
            return const Center(child: Text('No wallet data'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<WalletCubit>().refreshWallet(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BalanceCard(wallet: wallet),
                  const SizedBox(height: 20),
                  _QuickActions(),
                  const SizedBox(height: 24),
                  _TransactionsSection(transactions: wallet.transactions),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final WalletEntity wallet;

  const _BalanceCard({required this.wallet});

  String _formatCurrency(String balance) {
    final amount = double.tryParse(balance) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: customLinearGradient,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
                    wallet.currency,
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
              _formatCurrency(wallet.balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            if (wallet.updatedAt != null)
              Row(
                children: [
                  Icon(LucideIcons.clock,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last updated: ${DateFormat('dd MMM yyyy, HH:mm').format(wallet.updatedAt!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.plus,
            label: 'Top Up',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Top Up coming soon')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.send,
            label: 'Transfer',
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfer coming soon')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.wallet,
            label: 'Withdraw',
            onTap: () {
              Navigator.of(context)
                  .push<bool>(
                    MaterialPageRoute(
                      builder: (_) => RequestPayoutPage.withProvider(),
                    ),
                  )
                  .then((ok) {
                    if (ok == true && context.mounted) {
                      context.read<WalletCubit>().refreshWallet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payout requested')),
                      );
                    }
                  });
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: customLinearGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  final List<WalletTransactionEntity> transactions;

  const _TransactionsSection({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {

              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          _EmptyTransactions()
        else
          ...transactions.map((tx) => _TransactionCard(transaction: tx)),
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.receipt,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransactionEntity transaction;

  const _TransactionCard({required this.transaction});

  String _formatAmount(String? amount) {
    if (amount == null) return 'Rp 0';
    final value = double.tryParse(amount) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'topup':
      case 'top_up':
        return LucideIcons.plus;
      case 'withdraw':
        return LucideIcons.minus;
      case 'transfer':
        return LucideIcons.arrowLeftRight;
      case 'payment':
        return LucideIcons.creditCard;
      default:
        return LucideIcons.receipt;
    }
  }

  Color _getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'topup':
      case 'top_up':
        return Colors.green;
      case 'withdraw':
      case 'payment':
        return Colors.red;
      case 'transfer':
        return appSecondaryColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(transaction.type);
    final isIncome =
        transaction.type?.toLowerCase() == 'topup' ||
        transaction.type?.toLowerCase() == 'top_up';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(transaction.type),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? transaction.type ?? 'Transaction',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (transaction.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(transaction.createdAt!),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${_formatAmount(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
