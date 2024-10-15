import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Payment Method: Credit/Debit Card
            ElevatedButton.icon(
              onPressed: () {
                // Aquí puedes navegar a la pantalla de pago con tarjeta
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Pay with Credit/Debit Card'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment Method: PayPal
            ElevatedButton.icon(
              onPressed: () {
                // Aquí puedes agregar funcionalidad para pago con PayPal
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Pay with PayPal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
