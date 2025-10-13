// All Menu in one list
import 'package:coffee_shop/Features/Cart/provider/cart_provider.dart';
import 'package:coffee_shop/Features/Menu/Provider/firebase_menu_service.dart';
import 'package:coffee_shop/Features/Profile/Provider/voucher_provider.dart';
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
 Map<String, List<Map<String, dynamic>>> getLocalMenuData()
{
  return {
  'Coffee': [
      {
        "name": "Espresso",
        "type": "coffee",
        "rating": 4.8,
        "image":'Assets/Images/Espresso Coffee.jpg',
        "description": "Strong and rich black coffee shot.",
        "price":'80',
      },
      {
    "name": "Doppio",
    "type": "coffee",
    "rating": 4.7,
    "image": 'Assets/Images/Doppio.jpg',
    "description": "Double shot of espresso for a stronger kick.",
    "price":'160',
  },
  {
    "name": "Americano",
    "type": "coffee",
    "rating": 4.6,
    "image": 'Assets/Images/Iced Americano.jpg',
    "description": "Espresso diluted with hot water for a milder taste.",
    "price":'110',
  },
  {
    "name": "Café Macha",
    "type": "coffee",
    "rating": 4.5,
    "image": 'Assets/Images/Caffe Mocha.jpg',
    "description": "Espresso topped with a small amount of steamed milk.",
    "price":'130',
  },
  {
    "name": "Cappuccino",
    "type": "coffee",
    "rating": 4.9,
    "image": 'Assets/Images/cappucino.jpg',
    "description": "Classic Italian coffee with steamed milk and foam.",
    "price":'120',
  },
  {
    "name": "Affogato",
    "type": "coffee",
    "rating": 4.7,
    "image": 'Assets/Images/Affogato Coffee.jpg',
    "description": "Vanilla ice cream 'drowned' in hot espresso.",
    "price":'100',
  },
  {
    "name": "South Indian Coffee",
    "type": "coffee",
    "rating": 4.8,
    "image": 'Assets/Images/south indian coffee.jpg',
    "description": "Traditional filter coffee made with milk and decoction.",
    "price":'60',
  },
  {
    "name": "Hot Chocolate",
    "type": "coffee",
    "rating": 4.4,
    "image": 'Assets/Images/HotChocolateCoffee.jpg',
    "description": "Creamy hot cocoa topped with whipped cream.",
    "price":'100',
  },
  {
    "name": "Café Latte",
    "type": "coffee",
    "rating": 4.6,
    "image": 'Assets/Images/Pumpkin-Spice-Latte.png',
    "description": "Espresso with steamed milk and a touch of foam.",
    "price":'120',
  },
  {
    "name": "Hazelnut Café Latte",
    "type": "coffee",
    "rating": 4.7,
    "image": 'Assets/Images/Hazelnut latte.jpg',
    "description": "Creamy latte infused with hazelnut flavor.",
    "price":'170',
  },
  {
    "name": "Caramel Café Latte",
    "type": "coffee",
    "rating": 4.8,
    "image": 'Assets/Images/Caramel Macchiato.jpg',
    "description": "Smooth latte sweetened with rich caramel syrup.",
    "price":'160',
  },
    ],
    'Tea': [
      {
        "name": "Elaichi Tea",
        "type": "tea",
        "rating": 4.6,
        "image": 'Assets/Images/newarrives4.png',
        "description": "Flavored with aromatic cardamom for a refreshing twist.",
        "price":'450',
      },
  {
    "name": "Masala Tea",
    "type": "tea",
    "rating": 4.8,
    "image": 'Assets/Images/Masala Chai.jpg',
    "description": "Traditional spiced Indian tea brewed with milk and herbs.",
    "price":'450',
  },
  {
    "name": "Ginger Tea",
    "type": "tea",
    "rating": 4.7,
    "image": 'Assets/Images/ginger tea.jpg',
    "description": "Bold and zesty tea with the warmth of fresh ginger.",
    "price":'450',
  },
  {
    "name": "Chamomile Tea",
    "type": "tea",
    "rating": 4.5,
    "image": 'Assets/Images/Chamomile.jpg',
    "description": "Caffeine-free herbal tea known for its calming properties.",
    "price":'450',
  },
  {
    "name": "Lemon Tea",
    "type": "tea",
    "rating": 4.4,
    "image": 'Assets/Images/Lemon tea.jpg',
    "description": "Light and citrusy black tea with a hint of lemon.",
    "price":'450',
  },
  {
    "name": "Green Tea",
    "type": "tea",
    "rating": 4.3,
    "image": 'Assets/Images/Tea.jpg',
    "description": "Healthy antioxidant-rich tea with a clean taste.",
    "price":'450',
  },
  {
    "name": "Cardamom Tea",
    "type": "tea",
    "rating": 4.6,
    "image": 'Assets/Images/Untitled - Copy - Copy.jpg',
    "description": "Sweet-spiced tea infused with cardamom pods.",
    "price":'450',
  },
  {
    "name": "Assam Tea",
    "type": "tea",
    "rating": 4.7,
    "image": 'Assets/Images/Japanese Tea.jpg',
    "description": "Strong, full-bodied Indian black tea from Assam region.",
    "price":'450',
  },
    ],
     'Cooler': [
      {
        "name": "Leave Me Alone",
        "type": "cooler",
        "rating": 4.5,
        "image": 'Assets/Images/newarrives4.png',
        "description": "A mysterious blend of citrus and herbs for total chill.",
        "price":'450',
      },
      // ... rest of cooler items
        {
    "name": "Virgin Mojito",
    "type": "cooler",
    "rating": 4.8,
    "image": 'Assets/Images/newarrives3.png',
    "description": "Classic mint and lime mojito with soda, no alcohol.",
    "price":'450',
  },
  {
    "name": "Berry Bliss",
    "type": "cooler",
    "rating": 4.7,
    "image": 'Assets/Images/newarrives2.jpeg',
    "description": "Refreshing mix of strawberries, blueberries, and mint.",
    "price":'450',
  },
  {
    "name": "Pink Pop Fizz",
    "type": "cooler",
    "rating": 4.6,
    "image": 'Assets/Images/newarrives3.png',
    "description": "Bubbly rose-colored cooler with tangy raspberry flavor.",
    "price":'450',
  },
  {
    "name": "Cola Mojito",
    "type": "cooler",
    "rating": 4.4,
    "image": 'Assets/Images/newArrives1.jpeg',
    "description": "Fizzy cola with mint and lemon twist—mocktail style.",
    "price":'450',
  },
  {
    "name": "Blue Lagoon",
    "type": "cooler",
    "rating": 4.7,
    "image": 'Assets/Images/newArrives1.jpeg',
    "description": "Electric blue cooler with citrus and soda sparkle.",
    "price":'450',
  },
    ],
    'crisspyDeliciousMenu': [
      {
        "name": "Peri Peri French Fries",
        "type": "snack",
        "rating": 4.6,
        "image": 'Assets/Images/Pumpkin-Spice-Latte.png',
        "description": "Crispy fries tossed in spicy peri peri seasoning.",
        "price":'450',
      },
      // ... rest of snack items
       {
    "name": "Classic French Fries",
    "type": "snack",
    "rating": 4.5,
    "image": 'Assets/Images/French fries.jpg',
    "description": "Golden fried potato fries with classic salt seasoning.",
    "price":'450',
  },
  {
    "name": "Cheese Corn Bites",
    "type": "snack",
    "rating": 4.7,
    "image": 'Assets/Images/Baked Corn Fritter Bites.jpg',
    "description": "Cheesy bites filled with melted cheese and sweet corn.",
    "price":'450',
  },
  {
    "name": "Onion Rings",
    "type": "snack",
    "rating": 4.4,
    "image": 'Assets/Images/Keto Onion Rings - Ketogenic_com.jpg',
    "description": "Crispy battered onion rings fried to perfection.",
    "price":'450',
  },
  {
    "name": "Chicken Popcorn",
    "type": "snack",
    "rating": 4.8,
    "image": 'Assets/Images/Mini Chicken Cigars With Sweet and Sour Dipping Sauce Recipe  - Food_com - Copy.jpg',
    "description": "Bite-sized crispy chicken chunks, tender inside.",
    "price":'450',
  },
  {
    "name": "Chicken Nuggets",
    "type": "snack",
    "rating": 4.6,
    "image": 'Assets/Images/Delicious Chicken Nuggets Recipe for a Perfect Snack - Copy.jpg',
    "description": "Classic crispy coated chicken nuggets served hot.",
    "price":'450',
  },
  {
    "name": "Chicken Momos",
    "type": "snack",
    "rating": 4.7,
    "image": 'Assets/Images/Delicious Chicken Nuggets Recipe for a Perfect Snack - Copy.jpg',
    "description": "Steamed or fried dumplings stuffed with chicken filling.",
    "price":'450',
  },
  {
    "name": "Veg Momos",
    "type": "snack",
    "rating": 4.5,
    "image": 'Assets/Images/Baked Corn Fritter Bites.jpg',
    "description": "Soft dumplings filled with spiced vegetable stuffing.",
    "price":'450',
  },
  {
    "name": "Chicken Samosa",
    "type": "snack",
    "rating": 4.6,
    "image": 'Assets/Images/Delicious Chicken Nuggets Recipe for a Perfect Snack - Copy.jpg',
    "description": "Crispy pastry filled with minced chicken and spices.",
    "price":'450',
  },
  {
    "name": "Veg Samosa",
    "type": "snack",
    "rating": 4.5,
    "image": 'Assets/Images/Delicious Chicken Nuggets Recipe for a Perfect Snack - Copy.jpg',
    "description": "Golden fried samosa with savory vegetable stuffing.",
    "price":'450',
  },
  {
    "name": "Chicken Fingers",
    "type": "snack",
    "rating": 4.7,
    "image": 'Assets/Images/Mini Chicken Cigars With Sweet and Sour Dipping Sauce Recipe  - Food_com - Copy.jpg',
    "description": "Strips of crispy breaded chicken served with dip.",
    "price":'450',
  },
  {
    "name": "Chicken Cigars",
    "type": "snack",
    "rating": 4.6,
    "image": 'Assets/Images/Mini Chicken Cigars With Sweet and Sour Dipping Sauce Recipe  - Food_com - Copy.jpg',
    "description": "Thin rolls filled with spiced chicken, deep-fried crispy.",
    "price":'450',
  },
    ],
    'frozenFuelsMenu':[
       {
    "name": "Classic Cold Coffee",
    "type": "frozen",
    "rating": 4.7,
    "image": 'Assets/Images/Pumpkin-Spice-Latte.png',
    "description": "Chilled coffee blended with milk and ice, topped with foam.",
    "price":'450',
  },
  {
    "name": "Iced Berry Espresso",
    "type": "frozen",
    "rating": 4.6,
    "image": 'Assets/Images/Chocolate Bourbon Milkshake.jpg',
    "description": "Bold espresso shaken with mixed berry flavors and ice.",
    "price":'450',
  },
  {
    "name": "Iced Americano",
    "type": "frozen",
    "rating": 4.5,
    "image": 'Assets/Images/cappucino.jpg',
    "description": "Refreshing espresso over ice with cold water dilution.",
    "price":'450',
  },
  {
    "name": "Iced Cappuccino",
    "type": "frozen",
    "rating": 4.6,
    "image": 'Assets/Images/cappucino.jpg',
    "description": "A frosty twist on the classic cappuccino with foam and chill.",
    "price":'450',
  },
  {
    "name": "Vanilla Bliss",
    "type": "frozen",
    "rating": 4.8,
    "image": 'Assets/Images/Chocolate Bourbon Milkshake.jpg',
    "description": "Creamy vanilla cold coffee with smooth, sweet flavor.",
     "price":'450',
  },
  {
    "name": "Cookies N Cream",
    "type": "frozen",
    "rating": 4.9,
    "image": 'Assets/Images/cappucino.jpg',
    "description": "Rich milkshake blended with crunchy cookies and cream.",
    "price":'450',
  },
  {
    "name": "Rowtress Chocolates",
    "type": "frozen",
    "rating": 4.7,
    "image": 'Assets/Images/download.jpg',
    "description": "Decadent cold chocolate drink with premium Rowtress cocoa.",
    "price":'450',
  },
  {
    "name": "Chocolate Overloaded",
    "type": "frozen",
    "rating": 4.9,
    "image": 'Assets/Images/Chocolate Bourbon Milkshake.jpg',
    "description": "Thick chocolate shake packed with dark and milk chocolate.",
    "price":'450',
  },
  {
    "name": "Strawberry Milkshake",
    "type": "frozen",
    "rating": 4.6,
    "image": 'Assets/Images/straberry milkshake.jpg',
    "description": "Classic pink milkshake with real strawberry puree.",
    "price":'450',
  },
  {
    "name": "Mangoblast Milkshake",
    "type": "frozen",
    "rating": 4.5,
    "image": 'Assets/Images/straberry milkshake.jpg',
    "description": "Tropical mango milkshake bursting with flavor.",
    "price":'450',
  },
    ],
};
}