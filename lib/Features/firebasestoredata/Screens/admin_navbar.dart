// Features/Admin/admin_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/admin_provider.dart';
import 'Screens.dart';
import 'orders_screen.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(adminTabProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          _buildCustomTabBar(ref),

          // Content Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentScreen(currentTab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(WidgetRef ref) {
    final currentTab = ref.watch(adminTabProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(
            ref: ref,
            tab: AdminTab.items,
            currentTab: currentTab,
            icon: Icons.coffee,
            label: 'Items',
          ),
          _buildTabItem(
            ref: ref,
            tab: AdminTab.orders,
            currentTab: currentTab,
            icon: Icons.receipt_long,
            label: 'Orders',
          ),
          _buildTabItem(
            ref: ref,
            tab: AdminTab.offers,
            currentTab: currentTab,
            icon: Icons.local_offer,
            label: 'Offers',
          ),
          _buildTabItem(
            ref: ref,
            tab: AdminTab.vouchers,
            currentTab: currentTab,
            icon: Icons.card_giftcard,
            label: 'Vouchers',
          ),
          _buildTabItem(
            ref: ref,
            tab: AdminTab.analytics,
            currentTab: currentTab,
            icon: Icons.analytics,
            label: 'Sessional',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required WidgetRef ref,
    required AdminTab tab,
    required AdminTab currentTab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(adminTabProvider.notifier).state = tab,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(AdminTab tab) {
    switch (tab) {
      case AdminTab.items:
        return const Datadstore();
      case AdminTab.orders:
        return AdminOrdersScreen();
      case AdminTab.offers:
        return const OfferdataStoreScreen();
      case AdminTab.vouchers:
        return const VoucherdataStoreScreen();
      case AdminTab.analytics:
        return const Sessionalitems();
    }
  }
}
