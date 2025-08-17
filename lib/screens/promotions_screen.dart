import 'package:flutter/material.dart';
import '../widgets/SubscriptionWebView.dart';

class PromotionsScreen extends StatelessWidget {
	const PromotionsScreen({Key? key}) : super(key: key);

	void _openWebView(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => Dialog(
				child: SizedBox(
					width: 600,
					height: 800,
					child: SubscriptionWebView(
						onResult: (result) {
							// Handle result if needed
							Navigator.of(context).pop();
						},
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Promociones'),
				backgroundColor: const Color(0xFF7012DA),
				foregroundColor: Colors.white,
			),
			body: Center(
				child: ElevatedButton(
					onPressed: () => _openWebView(context),
					child: const Text('Abrir Suscripción WebView'),
				),
			),
		);
	}
}
