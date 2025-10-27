import 'package:coffee_exult_app/Authentication/auth_wrapper.dart';
import 'package:coffee_exult_app/Authentication/phone_auth.dart';
import 'package:coffee_exult_app/Features/Event/presentation/event_book.dart';
import 'package:coffee_exult_app/Features/Event/presentation/user_bookingscreen.dart';
import 'package:coffee_exult_app/Features/Home/Home.dart';
import 'package:coffee_exult_app/Features/Profile/presentation/coffeereferscreen.dart';
import 'package:coffee_exult_app/Features/Profile/presentation/order_screen.dart';
import 'package:coffee_exult_app/Features/Profile/presentation/voucher_screen.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/widget/admin_pannel.dart';
import 'package:coffee_exult_app/Features/payment/paymentmethods.dart';
import 'package:coffee_exult_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Features/Cart/Cart.dart';
import '../../Features/Map/Map.dart';
import '../../Features/Menu/Menu.dart';
import '../../Features/Profile/profile.dart';
import '../../Features/firebasestoredata/Screens/Screens.dart';

final GoRouter approuter = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthWrapper()),
    GoRoute(path: '/admin', builder: (context, state) => AdminPanel()),
    // GoRoute(path: '/', builder: (context, state) => const Datadstore()),
    // GoRoute(path: '/', builder: (context, state) => const PhoneAuth()),
    // GoRoute(path: '/', builder: (context, state) => const PhoneOTPVerification()),
    // GoRoute(path: '/', builder: (context, state) => const MainAppere()),
    GoRoute(path: '/Newarraivles', builder: (context, state) => NewArrivals()),
    GoRoute(
      path: '/my-bookings',
      builder: (context, state) => const UserBookingsScreen(),
    ),
    GoRoute(
      path: '/sessional-items',
      builder: (context, state) => Sessionalitems(),
    ),
    GoRoute(
      path: '/voucher-data',
      builder: (context, state) => VoucherdataStoreScreen(),
    ),
    GoRoute(
      path: '/offer-data',
      builder: (context, state) => OfferdataStoreScreen(),
    ),
    GoRoute(
      path: '/login-screen',
      builder: (context, state) => const PhoneAuth(),
    ),
    GoRoute(
      path: '/voucher-screen',
      builder: (context, state) => GiveVoucherScreen(),
    ),
    GoRoute(path: '/navbar', builder: (context, state) => const MainAppere()),

    // GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/menu/:category',
      builder: (context, state) {
        final categoryName = state.pathParameters['category']!;
        final items = state.extra as List<Map<String, dynamic>>;
        return CategoryItemsScreen(categoryName: categoryName, items: items);
      },
    ),
    GoRoute(
      path: '/product/:id',
      name: 'product',
      pageBuilder: (context, state) {
        final product = state.extra as Map<String, dynamic>;
        return MaterialPage(
          key: state.pageKey,
          child: ProductDetailsScreen(product: product),
        );
      },
    ),
    GoRoute(
      path: '/online-order',
      builder: (context, state) => const OnlineorderScreen(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/reward', builder: (context, state) => RewarsScreens()),

    GoRoute(
      path: '/notification',
      builder: (context, state) => NotificationScreen(),
    ),

    GoRoute(path: '/offer', builder: (context, state) => OfferScreen()),
    GoRoute(
      path: '/eventform',
      builder: (context, state) => EventBookingScreen(),
    ),
    GoRoute(path: '/shophour', builder: (context, state) => ShophourScreen()),
    GoRoute(
      path: '/favorite',
      builder: (context, state) => FavoriteMenuScreen(),
    ),
    GoRoute(
      path: '/toproduct',
      builder: (context, state) {
        final product = state.extra as Map<String, dynamic>;
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) {
        return PaymentSuccessScreen(
          paymentData: state.extra as Map<String, dynamic>? ?? {},
        );
      },
    ),
    GoRoute(
      path: '/payment-success',
      name: 'payment-success',
      builder: (context, state) {
        final paymentData = state.extra as Map<String, dynamic>?;
        return PaymentSuccessScreen(paymentData: paymentData ?? {});
      },
    ),
    GoRoute(
      path: '/billing-info',
      builder: (context, state) => const BillingInfoScreen(),
    ),
    GoRoute(
      path: '/best-seller',
      builder: (context, state) => const TopBestsellersScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/level-screen',
      builder: (context, state) => const LevelScreen(),
    ),
    GoRoute(
      path: '/location',
      builder: (context, state) => const LocationScreen(),
    ),
    //  GoRoute(
    //   path: '/recent-location',
    //   builder: (context, state) => const RecentOrderScreen(),
    // ),
    GoRoute(
      path: '/payment-method',
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    // GoRoute(
    //   path: '/Recent-order',
    //   builder: (context, state) {
    //     final paymentData = state.extra as Map<String, dynamic>?;
    //     return RecentOrderScreen(paymentData: paymentData ?? {});
    //   },
    // ),
    GoRoute(
      path: '/recent-order',
      builder: (context, state) => RecentOrdersScreen(),
    ),
    GoRoute(
      path: '/datastore',
      builder: (context, state) => const Datadstore(),
    ),
    // GoRoute(
    //   path: '/scratch-cart',
    //   builder: (context, state) => const ScratchCardsScreen(),
    // ),
    GoRoute(
      path: '/app-reference',
      builder: (context, state) => const CoffeeReferFriendScreen(),
    ),
    GoRoute(
      path: '/chat-screen',
      builder: (context, state) => const TwaktoScreen(),
    ),
    GoRoute(
      path: '/googlemap',
      builder: (context, state) => const MapScreen(
        latitude: 18.4475,
        longitude: 73.8232,
        address: 'Pune, Maharashtra, India',
      ),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Error: ${state.error}'))),
);
