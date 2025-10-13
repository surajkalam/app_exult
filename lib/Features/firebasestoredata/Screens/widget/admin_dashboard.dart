// screens/admin_dashboard.dart
import 'package:coffee_shop/Features/firebasestoredata/provider/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            
            const SizedBox(height: 32),
            
            // Quick Actions Section
            _buildQuickActionsSection(ref, context),
            
            const SizedBox(height: 32),
            
            // Performance Metrics
            _buildPerformanceMetrics(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6D4C41), // Dark brown
            Color(0xFF8D6E63), // Medium brown
            Color(0xFFBCAAA4), // Light brown
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.coffee, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coffee Shop Admin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage your coffee shop with ease',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_getCurrentDate()} • ${_getCurrentTime()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your coffee shop items and promotions',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85, // Adjusted aspect ratio to prevent overflow
          children: [
            _buildActionCard(
              'Items Store',
              Icons.coffee,
              Color(0xFF6D4C41),
              'Manage all coffee items, update prices, and modify details',
              Icons.arrow_forward,
              () => ref.read(adminStateProvider.notifier).state = 1,
            ),
            _buildActionCard(
              'Offers Store',
              Icons.local_offer,
              Color(0xFFE65100),
              'Create and manage special offers and discounts',
              Icons.arrow_forward,
              () => ref.read(adminStateProvider.notifier).state = 2,
            ),
            _buildActionCard(
              'Vouchers Store',
              Icons.card_giftcard,
              Color(0xFF2E7D32),
              'Generate and manage discount vouchers',
              Icons.arrow_forward,
              () => ref.read(adminStateProvider.notifier).state = 3,
            ),
            _buildActionCard(
              'New Arrivals',
              Icons.new_releases,
              Color(0xFF1565C0),
              'Add and manage new menu items',
              Icons.arrow_forward,
              () => ref.read(adminStateProvider.notifier).state = 4,
            ),
            _buildActionCard(
              'Seasonal Items',
              Icons.coffee_maker,
              Color(0xFF6A1B9A),
              'Manage seasonal specials and limited items',
              Icons.arrow_forward,
              () => ref.read(adminStateProvider.notifier).state = 5,
            ),
            _buildActionCard(
              'Add Offer Cart',
              Icons.add_shopping_cart,
              Color(0xFFC62828),
              'Create special offer combinations and bundles',
              Icons.arrow_forward,
              () => _showComingSoonDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Orders', '24', Icons.shopping_bag, Color(0xFF4CAF50)),
              _buildMetricItem('Revenue', '\$286', Icons.attach_money, Color(0xFF2196F3)),
              _buildMetricItem('Customers', '18', Icons.people, Color(0xFF9C27B0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, String description, IconData trailingIcon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding:  EdgeInsets.only(left: 14,right: 14,bottom: 6,top: 12), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added to prevent expansion
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color), // Reduced icon size
              ),
               SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                 maxLines: 1,
                  overflow: TextOverflow.ellipsis,
              ),
               SizedBox(height: 2),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 10, // Reduced font size
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2, // Increased to 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Row(
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 10, // Reduced font size
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(trailingIcon, size: 10, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: Text('Offer Cart feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF6D4C41))),
          ),
        ],
      ),
    );
  }
}