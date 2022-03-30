import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import '../blocs/bloc/pagar_bloc.dart';
import '../models/tarjeta_credito.dart';
import '../widgets/total_pay_button.dart';


class TarjetaScreen extends StatelessWidget {

  const TarjetaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final blocPagar = BlocProvider.of<PagarBloc>( context );
    final TarjetaCredito tarjeta = blocPagar.state.tarjeta!;

    return Scaffold(
      appBar: AppBar(
        title: const Text( 'Pagar' ),
        leading: IconButton(
          icon: const Icon( Icons.arrow_back ),
          onPressed: () {
            blocPagar.add( OnDesactivarTarjeta() );
            Navigator.pop( context );
          },
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          Container(),
          
          Hero(
            tag: BlocProvider.of<PagarBloc>( context ).state.tarjeta!.cardNumber,
            child: CreditCardWidget(
              cardNumber: tarjeta.cardNumberHidden, 
              expiryDate: tarjeta.expiracyDate, 
              cardHolderName: tarjeta.cardHolderName, 
              cvvCode: tarjeta.cvv, 
              showBackView: false,
              isHolderNameVisible: true,
              onCreditCardWidgetChange: ( creditCardBrand ) {}
            ),
          ),

          const Positioned(
            bottom: 0,
            child: TotalPayButton()
          )

        ]
      ),
   );
  }
}