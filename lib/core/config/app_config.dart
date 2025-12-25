class AppConfig {
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );
  
  static const String razorpayKeySecret = String.fromEnvironment(
    'RAZORPAY_KEY_SECRET',
    defaultValue: '',
  );
  
  static bool get hasValidKeys => razorpayKeyId.isNotEmpty && razorpayKeySecret.isNotEmpty;
  
  static const int subscriptionAmount = 9900;
  static const String appName = 'Bhagya Premium';
  static const String currencyCode = 'INR';
}
