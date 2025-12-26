// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:js_util';

void openRazorpayCheckout({
  required Map<String, dynamic> options,
  required void Function(String?, String?, String?) onSuccess,
  required void Function(int?, String?) onFailure,
}) {
  final jsOptions = _mapToJsObject(options);
  
  jsOptions['handler'] = js.allowInterop((dynamic response) {
    final paymentId = getProperty(response, 'razorpay_payment_id') as String?;
    final orderId = getProperty(response, 'razorpay_order_id') as String?;
    final signature = getProperty(response, 'razorpay_signature') as String?;
    onSuccess(paymentId, orderId, signature);
  });
  
  jsOptions['modal'] = js.JsObject.jsify({
    'ondismiss': js.allowInterop(() {
      onFailure(null, 'Payment cancelled by user');
    }),
    'confirm_close': true,
  });

  final razorpay = js.JsObject(js.context['Razorpay'], [jsOptions]);
  razorpay.callMethod('open', []);
}

dynamic _mapToJsObject(Map<String, dynamic> dartMap) {
  final jsObject = js.JsObject(js.context['Object']);
  dartMap.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      jsObject[key] = _mapToJsObject(value);
    } else {
      jsObject[key] = value;
    }
  });
  return jsObject;
}
