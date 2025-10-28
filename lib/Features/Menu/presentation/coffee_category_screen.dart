import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CoffeeCategoryScreen extends ConsumerWidget {
  const CoffeeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: AppBar(
        title: Text('Coffee Menu'),
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Congratulations banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Icon(Icons.celebration, color: Colors.green[600], size: 32),
                  SizedBox(height: 8),
                  Text(
                    '🎉 Free Coffee Claimed!',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Choose your free coffee below',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Coffee items grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: coffeeItems.length,
                itemBuilder: (context, index) {
                  final coffee = coffeeItems[index];
                  return _buildCoffeeCard(context, coffee, colorScheme, textTheme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoffeeCard(
    BuildContext context,
    Map<String, dynamic> coffee,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coffee image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(
                Icons.local_cafe,
                size: 48,
                color: Colors.brown[600],
              ),
            ),
          ),
          
          // Coffee details
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coffee['name'],
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    coffee['description'],
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _selectFreeCoffee(context, coffee['name']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectFreeCoffee(BuildContext context, String coffeeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 $coffeeName selected! Enjoy your free coffee!'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    // Navigate back to main screen after selection
    Future.delayed(Duration(seconds: 2), () {
      context.go('/navbar');
    });
  }

  // Sample coffee data
  List<Map<String, dynamic>> get coffeeItems => [
    {
      'name': 'Espresso',
      'description': 'Rich and bold coffee shot',
    },
    {
      'name': 'Americano',
      'description': 'Espresso with hot water',
    },
    {
      'name': 'Cappuccino',
      'description': 'Espresso with steamed milk foam',
    },
    {
      'name': 'Latte',
      'description': 'Espresso with steamed milk',
    },
    {
      'name': 'Mocha',
      'description': 'Espresso with chocolate',
    },
    {
      'name': 'Macchiato',
      'description': 'Espresso with milk foam',
    },
  ];
}