// screens/admin_panel.dart
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/Menus/item_store.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/booking/admin_booking.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/offer_data.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/orders_screen.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/voucher/voucher_storescreen.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/widget/admin_dashboard.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/provider/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({super.key});

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  final List<Widget> _screens = [
    const AdminDashboard(),
    const ItemsStoreScreen(),
    const OfferdataStoreScreen(),
    const VoucherStoreScreen(),
    const AdminBookingsScreen(),
    AdminOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(adminStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Shop Admin Panel'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(currentIndex),
      body: _screens[currentIndex],
    );
  }

  Widget _buildDrawer(int currentIndex) {
    return Drawer(
      child: Container(
        color: Colors.brown[50],
        child: Consumer(
          builder: (context, ref, child) {
            final statsAsync = ref.watch(statsProvider);

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.brown[800]!, Colors.brown[400]!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.coffee,
                          size: 35,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(height: 10),
                      const Text(
                        'Coffee Shop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Admin Panel',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Navigation Items
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  currentIndex: currentIndex,
                ),
                _buildDrawerItem(
                  icon: Icons.coffee,
                  title: 'Items Store',
                  index: 1,
                  currentIndex: currentIndex,
                ),
                _buildDrawerItem(
                  icon: Icons.local_offer,
                  title: 'Offers Store',
                  index: 2,
                  currentIndex: currentIndex,
                ),
                _buildDrawerItem(
                  icon: Icons.card_giftcard,
                  title: 'Vouchers Store',
                  index: 3,
                  currentIndex: currentIndex,
                ),
                _buildDrawerItem(
                  icon: Icons.functions,
                  title: 'Events',
                  index: 4,
                  currentIndex: currentIndex,
                ),
                _buildDrawerItem(
                  icon: Icons.bike_scooter,
                  title: 'Order ',
                  index: 5,
                  currentIndex: currentIndex,
                ),
                const Divider(),
                // Statistics Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                ),

                // Stats from Provider
                statsAsync.when(
                  data: (stats) => Column(
                    children: [
                      _buildStatItem(
                        'Total Items',
                        stats['totalItems'].toString(),
                        Icons.inventory,
                      ),
                      _buildStatItem(
                        'Active Offers',
                        stats['activeOffers'].toString(),
                        Icons.local_offer,
                      ),
                      _buildStatItem(
                        'Vouchers',
                        stats['vouchers'].toString(),
                        Icons.card_giftcard,
                      ),
                      _buildStatItem(
                        'New Arrivals',
                        stats['newArrivals'].toString(),
                        Icons.new_releases,
                      ),
                      _buildStatItem(
                        'Seasonal Items',
                        stats['seasonalItems'].toString(),
                        Icons.coffee_maker,
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading stats: $error'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required int currentIndex,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: currentIndex == index ? Colors.brown : Colors.brown[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: currentIndex == index
              ? FontWeight.bold
              : FontWeight.normal,
          color: currentIndex == index ? Colors.brown : Colors.brown[700],
        ),
      ),
      trailing: currentIndex == index
          ? Icon(Icons.arrow_forward, color: Colors.brown, size: 16)
          : null,
      onTap: () {
        ref.read(adminStateProvider.notifier).state = index;
        Navigator.pop(context);
      },
      tileColor: currentIndex == index ? Colors.brown[100] : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.brown[700]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
