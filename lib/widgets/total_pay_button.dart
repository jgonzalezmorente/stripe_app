import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_app/blocs/bloc/pagar_bloc.dart';
import 'package:stripe_app/services/stripe_service.dart';
import '../helpers/helpers.dart';


class TotalPayButton extends StatelessWidget {
  const TotalPayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final pagarBloc = BlocProvider.of<PagarBloc>( context ).state;

    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text( '${ pagarBloc.montoPagar } ${ pagarBloc.moneda }', style: const TextStyle(fontSize: 20))
            ],
          ),
          BlocBuilder<PagarBloc, PagarState>(
            builder: ( context, state ) => _BtnPay( state.tarjetaActiva )
          )
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {

  final bool tarjetaActiva;

  const _BtnPay(
    this.tarjetaActiva,
  {
    Key? key,     
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return tarjetaActiva ? buildBotonTarjeta( context ) : buildAppleAndGooglePay( context );
  }

  Widget buildBotonTarjeta(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 170,
        shape: const StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        child: Row(
          children: const [
            Icon(FontAwesomeIcons.solidCreditCard, color: Colors.white),
            Text('  Pagar', style: TextStyle(color: Colors.white, fontSize: 22))
          ],
        ),
        onPressed: () async {

          final stripService = StripService();
          final state        = BlocProvider.of<PagarBloc>( context ).state;
          final tarjeta      = state.tarjeta;
          final mesAnio      = tarjeta!.expiracyDate.split('/');

          mostrarLoading( context );

          final resp = await stripService.pagarConTarjetaExistente(
            amount: state.montoPagarString, 
            currency: state.moneda, 
            card: CreditCard(
              number: tarjeta.cardNumber,
              expMonth: int.parse( mesAnio[0] ),
              expYear: int.parse( mesAnio[1] ),
            )
          );

          Navigator.pop( context );

          if ( resp.ok ) {
            mostrarAlerta( context, 'Tarjeta OK', 'Todo correcto' );
          } else {
            mostrarAlerta( context, 'Algo salió mal', resp.msg ?? '' );
          }

        });
  }

  Widget buildAppleAndGooglePay(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: const StadiumBorder(),
        elevation: 0,
        color: Colors.black,
        child: Row(
          children: [
            Icon(
              Platform.isAndroid
                  ? FontAwesomeIcons.google
                  : FontAwesomeIcons.apple,
              color: Colors.white,
            ),
            const Text(' Pay', style: TextStyle(color: Colors.white, fontSize: 22) )
          ],
        ),
        onPressed: () async {          
          final stripService = StripService();
          final state        = BlocProvider.of<PagarBloc>( context ).state;

          await stripService.pagarConApplePayGooglePay(
            amount: state.montoPagarString, 
            currency: state.moneda
          );

        });
  }
}
