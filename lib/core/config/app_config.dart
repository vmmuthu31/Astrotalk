class AppConfig {
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_Rueu54gtxBoca0',
  );
  
  static const String razorpayKeySecret = String.fromEnvironment(
    'RAZORPAY_KEY_SECRET',
    defaultValue: '3q6qXC1UR9k3IAYambZQb7B8',
  );
  
  static bool get hasValidKeys => razorpayKeyId.isNotEmpty && razorpayKeySecret.isNotEmpty;
  
  static const int subscriptionAmount = 9900;
  static const String appName = 'Bhagya Premium';
  static const String currencyCode = 'INR';
}
