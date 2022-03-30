import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:stripe_app/blocs/bloc/pagar_bloc.dart';
import 'package:stripe_app/data/tarjetas.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/screens/screens.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_app/widgets/total_pay_button.dart';


class HomeScreen extends StatelessWidget {

  final stripService = StripService();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of( context ).size;
    final pagarBloc = BlocProvider.of<PagarBloc>( context );
    
    return Scaffold(
      appBar: AppBar( 
        title: const Text( 'Pagar' ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon( Icons.add ),
            onPressed: () async {

              mostrarLoading(context);

              final amount = pagarBloc.state.montoPagarString;
              final currency = pagarBloc.state.moneda;

              final resp = await stripService.pagarConNuevaTarjeta(
                amount: amount, 
                currency: currency
              );

              Navigator.pop( context );

              if ( resp.ok ) {
                mostrarAlerta( context, 'Tarjeta OK', 'Todo correcto' );
              } else {
                mostrarAlerta( context, 'Algo salió mal', resp.msg ?? '' );
              }

            }, 
          )
        ]
      ),
      body: Stack(
        children: [
          Positioned(
            width: size.width,
            height: size.height,
            top: 200,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.9
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: tarjetas.length,
              itemBuilder: ( _ , i ) {
          
                final tarjeta = tarjetas[ i ];
                return GestureDetector(
                  onTap: () {                    
                    BlocProvider.of<PagarBloc>( context ).add( OnSeleccionarTarjeta( tarjeta ) );
                    Navigator.push( context, navegarFadeIn(context, const TarjetaScreen() ) );
                  },  
                  child: Hero(
                    tag: tarjeta.cardNumber,
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
                );
              }
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