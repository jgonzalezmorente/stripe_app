import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class PagoCompletoScreen extends StatelessWidget {

  const PagoCompletoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text( 'Pago realizado' ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon( FontAwesomeIcons.star, color: Colors.white54, size: 100 ),
            SizedBox( height: 20 ),
            Text( 'Pago realizado correctamente!', style: TextStyle( color: Colors.white, fontSize: 22 ) )
          ]
        ),
     ),
   );
  }
}