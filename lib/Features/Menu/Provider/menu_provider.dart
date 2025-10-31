// All Menu in one list
import 'package:coffee_exult_app/Features/Cart/provider/cart_provider.dart';
import 'package:coffee_exult_app/Features/Menu/Provider/firebase_menu_service.dart';
import 'package:coffee_exult_app/Features/Profile/Provider/voucher_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final List offerlist = [
  {
    "name": "Espresso",
    "type": "coffee",
    "rating": 4.8,
    "image": 'Assets/Images/Chocolate Bourbon Milkshake.jpg',
    "description": "Strong and rich black coffee shot.",
    "price": '80',

  },
  {
    "name": "Elaichi Tea",
    "type": "tea",
    "rating": 4.6,
    "image": 'Assets/Images/newarrives4.png',
    "description": "Flavored with aromatic cardamom for a refreshing twist.",
    "price": '450',
  },
  {
    "name": "Elaichi Tea",
    "type": "tea",
    "rating": 4.6,
    "image": 'Assets/Images/newarrives4.png',
    "description": "Flavored with aromatic cardamom for a refreshing twist.",
    "price": '450',
  },
];
// Pricing calculator (static methods - safe for build)
class PricingCalculator {
  static const double deliveryCharge = 40.00;
  static const double serviceCharge = 10.87;
  static const double taxRate = 0.10; // 10%
  //  static const double deliveryCharge = 00;
  // static const double serviceCharge = 00;
  // static const double taxRate = 0.0; // 10%

  // Calculate pricing without modifying providers (safe for build)
  static PricingResult calculatePricing({
    required double subtotal,
    double voucherDiscountPercentage = 0.0,
    bool includeDelivery = true,
    bool includeTax = true,
  }) {
    final calculatedTax = includeTax ? subtotal * taxRate : 0.0;
    final calculatedDelivery = includeDelivery ? deliveryCharge : 0.0;
    final calculatedService = includeDelivery ? serviceCharge : 0.0;
    final discountAmount = (subtotal * voucherDiscountPercentage) / 100;
    
    final grandTotal = (subtotal + calculatedDelivery + calculatedService + calculatedTax) - discountAmount;

    return PricingResult(
      subtotal: subtotal,
      deliveryCharge: calculatedDelivery,
      serviceCharge: calculatedService,
      tax: calculatedTax,
      discountAmount: discountAmount,
      voucherDiscountPercentage: voucherDiscountPercentage,
      grandTotal: grandTotal,
    );
  }
}

// Pricing result model (immutable)
class PricingResult {
  final double subtotal;
  final double deliveryCharge;
  final double serviceCharge;
  final double tax;
  final double discountAmount;
  final double voucherDiscountPercentage;
  final double grandTotal;
  const PricingResult({
    required this.subtotal,
    required this.deliveryCharge,
    required this.serviceCharge,
    required this.tax,
    required this.discountAmount,
    required this.voucherDiscountPercentage,
    required this.grandTotal,
  });
  @override
  String toString() {
    return 'PricingResult(subtotal: $subtotal, delivery: $deliveryCharge, service: $serviceCharge, tax: $tax, discount: $discountAmount, grandTotal: $grandTotal)';
  }
}
// Provider to calculate pricing based on cart and voucher (reactive)
final cartPricingProvider = Provider<PricingResult>((ref) {
  final cartState = ref.watch(cartProvider);
  final voucherDiscount = ref.watch(voucherDiscountProvider);
  return cartState.when(
    data: (items) {
      final subtotal = items.fold(0.0, (sum, item) {
        return sum + (item['price'] * (item['quantity'] ?? 1));
      });
      return PricingCalculator.calculatePricing(
        subtotal: subtotal,
        voucherDiscountPercentage: voucherDiscount,
        includeDelivery: true,
        includeTax: true,
      );
    },
    loading: () => PricingCalculator.calculatePricing(
      subtotal: 0.0,
      voucherDiscountPercentage: 0.0,
    ),
    error: (error, stack) => PricingCalculator.calculatePricing(
      subtotal: 0.0,
      voucherDiscountPercentage: 0.0,
    ),
  );
});

// Provider for product details pricing
final productPricingProvider = Provider.family<PricingResult, double>((ref, subtotal) {
  final voucherDiscount = ref.watch(voucherDiscountProvider);
  
  return PricingCalculator.calculatePricing(
    subtotal: subtotal,
    voucherDiscountPercentage: voucherDiscount,
    includeDelivery: true, // Set to false if you don't want delivery in product screen
    includeTax: true,      // Set to false if you don't want tax in product screen
  );
});
final  menuCategoriesProvider = FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) async {
  final firebaseService = FirebaseMenuService();
  try {
    return await firebaseService.getMenuItems();
  } catch (e) {
    // return getLocalMenuData();
    return {
      'Coffee': [],
      'Tea': [],
      'Cooler': [],
      'crisspyDeliciousMenu': [],
      'frozenFuelsMenu': []
    };
  }
});