import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRCodeScreen extends StatelessWidget {
  final String dataToEncode;

  const GenerateQRCodeScreen({super.key, required this.dataToEncode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: QrImageView(
            version: QrVersions.auto,
        data: dataToEncode,
        backgroundColor: Colors.black,
        // ignore: deprecated_member_use
        foregroundColor: Theme.of(context).colorScheme.primary,
      )),
    );
  }
}
