import 'package:dio/dio.dart';
import 'package:stripe_app/models/payment_intent_response.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:stripe_app/models/stripe_custom_response.dart';



class StripService {

  StripService._privateConstructor();
  static final StripService _instance = StripService._privateConstructor();
  factory StripService() => _instance;

  final String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static const String _secretKey = '';
  final String _apiKey = '';
  
  final headerOptions = Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      'Authorization': 'Bearer ${ StripService._secretKey }'
    }
  );

  void init() {

    StripePayment.setOptions(
      StripeOptions(
        publishableKey: _apiKey,
        androidPayMode: 'test',
        merchantId: 'test'
      )
    );



  }

  Future<StripeCustomResponse> pagarConTarjetaExistente({
    required String amount,
    required String currency,
    required CreditCard card
  }) async {


    try {

      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest( card: card )
      );

      final resp = await _realizarPago(
        amount: amount, 
        currency: currency, 
        paymentMethod: paymentMethod
      );

      return resp;

    } catch (e) {

      return StripeCustomResponse(
        ok: false,
        msg: e.toString()
      );

    }



  }

  Future<StripeCustomResponse> pagarConNuevaTarjeta({
    required String amount,
    required String currency
  }) async {

    try {

      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest()
      );

      final resp = await _realizarPago(
        amount: amount, 
        currency: currency, 
        paymentMethod: paymentMethod
      );

      return resp;

    } catch (e) {

      return StripeCustomResponse(
        ok: false,
        msg: e.toString()
      );

    }


  }

  Future pagarConApplePayGooglePay({
    required String amount,
    required String currency
  }) async {

    try {

      final newAmount = double.parse( amount ) / 100;      

      final token = await StripePayment.paymentRequestWithNativePay(

        androidPayOptions: AndroidPayPaymentRequest(
          currencyCode: currency, 
          totalPrice: amount
        ),

        applePayOptions: ApplePayPaymentOptions(
          countryCode: 'US',
          currencyCode: currency,
          items: [
            ApplePayItem(
              label: 'Super producto 1',
              amount: '$newAmount'
            )
          ]
        )
      );

      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            token: token.tokenId
          )
        )
      );

      final resp = await _realizarPago(
        amount: amount, 
        currency: currency, 
        paymentMethod: paymentMethod
      );

      await StripePayment.completeNativePayRequest();

      return resp;      
      
    } catch (e) {

      return StripeCustomResponse(
        ok: false,
        msg: e.toString()
      );

    }

  }

  Future<PaymentIntentResponse> _crearPaymentIntent({
    required String amount,
    required String currency
  }) async {

    try {

      final dio = Dio();

      final data = {
        'amount': amount,
        'currency': currency
      };

      final resp = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions
      );

      return PaymentIntentResponse.fromMap( resp.data );
      
    } catch (e) {

      return PaymentIntentResponse(
        status: '400'
      );

    }

  }

  Future<StripeCustomResponse> _realizarPago({
    required String amount,
    required String currency,
    required PaymentMethod paymentMethod
  }) async {

    try {
      
      final paymentIntent = await _crearPaymentIntent(
        amount: amount,
        currency: currency
      );

      final paymentResult = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent.clientSecret,
          paymentMethodId: paymentMethod.id
        )
      );

      if ( paymentResult.status == 'succeeded' ) {
        return StripeCustomResponse( ok: true );
      } else {
        return StripeCustomResponse(
          ok: false,
          msg: 'Fallo ${ paymentResult.status }'
        );
      }

    } catch (e) {      

      return StripeCustomResponse(
        ok: false,
        msg: e.toString()
      );

    }


  }


}