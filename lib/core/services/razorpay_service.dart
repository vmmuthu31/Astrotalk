import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/app_config.dart';

typedef PaymentSuccessCallback = void Function(PaymentSuccessResponse response);
typedef PaymentFailureCallback = void Function(PaymentFailureResponse response);
typedef ExternalWalletCallback = void Function(ExternalWalletResponse response);

class RazorpayService {
  late Razorpay _razorpay;
  String? _planId;
  String? _currentSubscriptionId;
  
  PaymentSuccessCallback? onPaymentSuccess;
  PaymentFailureCallback? onPaymentFailure;
  ExternalWalletCallback? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

  String get _authHeader {
    final authString = base64Encode(
      utf8.encode('${AppConfig.razorpayKeyId}:${AppConfig.razorpayKeySecret}'),
    );
    return 'Basic $authString';
  }

  Future<String?> createPlan() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/plans'),
        headers: {
          'Authorization': _authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'period': 'monthly',
          'interval': 1,
          'item': {
            'name': 'Bhagya Premium Monthly',
            'amount': 9900,
            'currency': 'INR',
            'description': 'Monthly subscription for Bhagya Premium features',
          },
          'notes': {
            'app': 'bhagya',
            'type': 'monthly_subscription',
          },
        }),
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

      final now = DateTime.now();
      final expireBy = now.add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
      
      final Map<String, dynamic> requestBody = {
        'plan_id': planId,
        'total_count': 12,
        'quantity': 1,
        'customer_notify': 1,
        'expire_by': expireBy,
        'notify_info': {
          'notify_phone': customerPhone,
        },
      };

      if (startAtUnix != null) {
        requestBody['start_at'] = startAtUnix;
      }

      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/subscriptions'),
        headers: {
          'Authorization': _authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
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

      var options = {
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

      _razorpay.open(options);
      return true;
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      return false;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
