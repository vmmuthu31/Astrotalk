void openRazorpayCheckout({
  required Map<String, dynamic> options,
  required void Function(String?, String?, String?) onSuccess,
  required void Function(int?, String?) onFailure,
}) {
  throw UnsupportedError('Razorpay web is only supported on web platform');
}
