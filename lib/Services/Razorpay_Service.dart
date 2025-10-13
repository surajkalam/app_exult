// ignore: file_names
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onError;

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String amount,
    required String name,
    required String description,
    required String orderId,
    String? contact,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;

    var options = {
      // 'key': 'rzp_test_R7HT7by76iqrT3',
      'key':'rzp_live_RBwl23R7CRkmJJ',
      'amount': amount,
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact ?? 'Guest',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (kDebugMode) {
        print('Razorpay Error: $e');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (kDebugMode) {
      print('Payment Success: ${response.paymentId}');
    }
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('Payment Error: ${response.code} - ${response.message}');
    }
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('External Wallet: ${response.walletName}');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}