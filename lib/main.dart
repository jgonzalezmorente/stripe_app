import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_app/blocs/bloc/pagar_bloc.dart';
import 'package:stripe_app/screens/screens.dart';
import 'package:stripe_app/services/stripe_service.dart';

void main() => runApp ( const MyApp() );

class MyApp extends StatelessWidget {
  
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    StripService().init();

    return MultiBlocProvider(
      providers: [
        BlocProvider( create: ( _ ) => PagarBloc() )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StripeApp',
        initialRoute: 'home',
        routes: {
          'home': ( _ ) => HomeScreen(),
          'pago_completo': ( _ ) => const PagoCompletoScreen(),
        },
        theme: ThemeData.light().copyWith(
          appBarTheme: const AppBarTheme( color: Color( 0xff284879 ) ),
          primaryColor: const Color( 0xff284879 ),
          scaffoldBackgroundColor: const Color( 0xff21232a )
        ),
      ),
    );
  }
}