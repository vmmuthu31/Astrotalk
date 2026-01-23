import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/app_config.dart';
import 'api_service.dart';

import 'razorpay_web_stub.dart'
    if (dart.library.html) 'razorpay_web_impl.dart' as razorpay_web;

typedef PaymentSuccessCallback = void Function(PaymentSuccessResponse response);
typedef PaymentFailureCallback = void Function(PaymentFailureResponse response);
typedef ExternalWalletCallback = void Function(ExternalWalletResponse response);

typedef WebPaymentSuccessCallback = void Function(String? paymentId, String? orderId, String? signature);
typedef WebPaymentFailureCallback = void Function(int? code, String? message);

class RazorpayService {
  Razorpay? _razorpay;
  String? _planId;
  String? _currentSubscriptionId;
  bool get _isWebPlatform => kIsWeb;
  
  static const String _backendUrl = 'https://astrotalk-be.vercel.app/api/payment';
  
  PaymentSuccessCallback? onPaymentSuccess;
  PaymentFailureCallback? onPaymentFailure;
  ExternalWalletCallback? onExternalWallet;
  
  WebPaymentSuccessCallback? onWebPaymentSuccess;
  WebPaymentFailureCallback? onWebPaymentFailure;

  RazorpayService() {
    if (!_isWebPlatform) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    onPaymentFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  Future<String?> createPlan() async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/create-plan'),
        headers: {'Content-Type': 'application/json'},
        body: '{}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _planId = data['id'];
        debugPrint('Plan created: $_planId');
        return _planId;
      } else {
        debugPrint('Plan creation failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating plan: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createSubscription({
    required String customerPhone,
    int? startAtUnix,
  }) async {
    try {
      String? planId = _planId;
      if (planId == null) {
        planId = await createPlan();
        if (planId == null) {
          debugPrint('Failed to create plan');
          return null;
        }
      }

      final response = await http.post(
        Uri.parse('$_backendUrl/create-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'planId': planId,
          'customerPhone': customerPhone,
          'startAt': startAtUnix,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _currentSubscriptionId = data['id'];
        debugPrint('Subscription created: $_currentSubscriptionId');
        return data;
      } else {
        debugPrint('Subscription creation failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      return null;
    }
  }

  Future<bool> verifyPayment({
    required String paymentId,
    required String subscriptionId, 
    required String signature,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'razorpay_subscription_id': subscriptionId,
          'razorpay_signature': signature,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Payment verified successfully');
        return true;
      } else {
        debugPrint('Payment verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    }
  }

  Future<bool> openNativeCheckout({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    bool isTrial = false,
  }) async {
    try {
      int? startAt;
      if (isTrial) {
        final trialEnd = DateTime.now().add(const Duration(days: 7));
        startAt = trialEnd.millisecondsSinceEpoch ~/ 1000;
      }

      final subscription = await createSubscription(
        customerPhone: customerPhone,
        startAtUnix: startAt,
      );

      if (subscription == null) {
        debugPrint('Failed to create subscription');
        return false;
      }

      final subscriptionId = subscription['id'] as String;

      final options = {
        'key': AppConfig.razorpayKeyId,
        'subscription_id': subscriptionId,
        'name': 'Bhagya Premium',
        'description': isTrial 
            ? 'Monthly Subscription (7-day free trial)' 
            : 'Monthly Subscription - ₹99/month',
        'prefill': {
          'name': customerName,
          'email': customerEmail,
          'contact': customerPhone,
        },
        'theme': {
          'color': '#6B21A8',
        },
        'modal': {
          'confirm_close': true,
        },
      };

      if (_isWebPlatform) {
        razorpay_web.openRazorpayCheckout(
          options: options,
          onSuccess: (paymentId, orderId, signature) {
            debugPrint('Web Payment Success: $paymentId');
            onWebPaymentSuccess?.call(paymentId, orderId, signature);
            final response = PaymentSuccessResponse(paymentId, orderId, signature, null);
            onPaymentSuccess?.call(response);
          },
          onFailure: (code, message) {
            debugPrint('Web Payment Failed: $code - $message');
            onWebPaymentFailure?.call(code, message);
            final response = PaymentFailureResponse(code ?? 0, message ?? 'Payment failed', null);
            onPaymentFailure?.call(response);
          },
        );
        return true;
      } else {
        _razorpay?.open(options);
        return true;
      }
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      return false;
    }
  }

  void dispose() {
    _razorpay?.clear();
  }
}
