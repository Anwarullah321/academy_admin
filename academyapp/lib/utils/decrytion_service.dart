import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'my_keys.dart';
import 'nexasoft_license_generator.dart';
import 'shuffling_and_masking.dart';

class DecrytionService {
  /// Function to verify the license
  static Future<void> verifyLicense(String license) async {
    List<String> licenseParts = license.split('|||||');
    if (licenseParts.length != 2) {
      throw Exception('Invalid license format');
    }

    String cipher = licenseParts[0];
    String sign = licenseParts[1];

    // Decrypt and verify license data
    String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPrivate, "private");
    String publicKeySign = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPublicKeySign, "public");

    // Decrypt the license content
    String decryptedData = await NexaSoftLicenseGenrator.decryptString(
        encryptedText: cipher, privateKey: privateKey);

    // Verify the signature
    Uint8List signature = base64.decode(sign);
    bool isVerified = NexaSoftLicenseGenrator.verifySignatureWithPublicKey(
        data: cipher, signature: signature, publicKey: publicKeySign);

    if (!isVerified) {
      throw Exception("Invalid license signature");
    }

    // Check device registration and validity
    Map<String, dynamic> data = jsonDecode(decryptedData);
    await _checkDeviceAndValidity(data);
  }

  /// Function to decrypt, check, and show license data
  static Future<void> decryptTheCipher({
    required String cipher,
    required String sign,
    required BuildContext context,
  }) async {
    String privateKey = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPrivate, "private");
    String publicKeySign = MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
        MyKey.encPublicKeySign, "public");

    // Decrypt the data
    String decryptedData = await NexaSoftLicenseGenrator.decryptString(
        encryptedText: cipher, privateKey: privateKey);
    Uint8List signature = base64.decode(sign);

    // Verify the signature
    bool verify = NexaSoftLicenseGenrator.verifySignatureWithPublicKey(
        data: cipher, signature: signature, publicKey: publicKeySign);

    // Extract and validate the data
    Map<String, dynamic> data = jsonDecode(decryptedData);
    await _checkDeviceAndValidity(data);

    // Show appropriate feedback to the user
    if (verify) {
      _showVerificationDialog(context);
    } else {
      _showErrorSnackbar(context, "Invalid Code");
    }
  }

  static Future<void> _checkDeviceAndValidity(Map<String, dynamic> data) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check license expiration
    if (int.parse(data['year']) < currentTime) {
      throw Exception("License expired");
    }

    // Check device registration
    List<bool> checkIfAlreadyRegistered =
    await FirestoreService.checkIfAlreadyRegistered(data['rollNo']);
    if (!checkIfAlreadyRegistered[0] && checkIfAlreadyRegistered[1]) {
      await FirestoreService.registerADevice(data['rollNo']);
    } else if (checkIfAlreadyRegistered[0]) {
      throw Exception("This license is already registered to another device");
    }
  }

  static void _showVerificationDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 100,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "License Verified",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
